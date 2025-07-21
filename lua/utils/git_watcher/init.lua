local M = {}

local vim = vim

-- Global state variables
M.enabled = true
INTERVAL = 2000
local debounce_interval = INTERVAL
M.min_log_level = vim.log.levels.WARN
local native_notify = vim.notify or vim.notify_once

M.select_prompt_active = false
M.input_prompt_active = false

-- Helper functions for state management
local function get_debounce_interval()
	return debounce_interval
end

local function set_debounce_interval(value)
	debounce_interval = value
end

local function get_select_prompt_active()
	return M.select_prompt_active
end

local function set_select_prompt_active(value)
	M.select_prompt_active = value
end

local function get_input_prompt_active()
	return M.input_prompt_active
end

local function set_input_prompt_active(value)
	M.input_prompt_active = value
end

-- Initialize notifier
local notifier_module = require("utils.git_watcher.notifier")
local notify = notifier_module.setup(M.min_log_level, native_notify)

-- Require other modules
local git_utils = require("utils.git_watcher.git_utils")
local prompts = require("utils.git_watcher.prompts")
local core = require("utils.git_watcher.core")
local watcher = require("utils.git_watcher.watcher")

-- Public API functions
function M.check_local_changes()
	notify(M.select_prompt_active)
	if not M.enabled or M.select_prompt_active or M.input_prompt_active then return end

	local Job = require("plenary.job")
	Job:new({
		command = "git",
		args = { "rev-parse", "--show-toplevel" },
		timeout = 5000,
		on_exit = function(root_job)
			vim.schedule(function()
				local git_root_path = root_job:result()[1]
				if git_root_path then
					core.perform_check_local_changes(git_root_path, git_utils, prompts, notify, get_select_prompt_active,
						set_select_prompt_active, set_input_prompt_active, set_debounce_interval, get_debounce_interval)
				else
					notify("Could not determine Git repository root.", vim.log.levels.ERROR)
				end
			end)
		end,
	}):start()
end

function M.toggle()
	M.enabled = not M.enabled
	notify("Git watcher " .. (M.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

function M.set_log_level(log_level)
	M.min_log_level = log_level
	-- Re-setup notifier with new log level
	notify = notifier_module.setup(M.min_log_level, native_notify)
end

function M.reset_interval()
	debounce_interval = INTERVAL
	notify("[GitWatcher] Debounced timer reset to " .. debounce_interval, vim.log.levels.WARN)
end

function M.start_watcher()
	watcher.start_watcher(notify, M.check_local_changes, get_debounce_interval)
end

return M
