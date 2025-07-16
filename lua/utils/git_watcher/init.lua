local M = {}
-- Global toggle to disable watcher temporarily
M.enabled = true

local vim = vim
local debounce_interval = 1000
M.min_log_level = vim.log.levels.WARN
local native_notify = vim.notify or vim.notify_once

-- Track if we have an active select prompt or input prompt
M.select_prompt_active = false
M.input_prompt_active = false

-- Improved notification system with rate limiting
local notify = function(msg, level, opts)
	level = level or vim.log.levels.INFO
	if level >= M.min_log_level then
		native_notify(msg, level, opts)
	end
end

-- Count lines changed (added/modified/deleted)
local function count_changed_lines(callback)
	local Job = require("plenary.job")
	Job:new({
		command = "git",
		args = { "diff", "--numstat" },
		timeout = 10000,
		on_exit = function(j)
			local lines = j:result()
			local total = 0
			for _, line in ipairs(lines) do
				local added, deleted = line:match("(%d+)%s+(%d+)")
				if added and deleted then
					total = total + tonumber(added) + tonumber(deleted)
				end
			end

			vim.schedule(function()
				callback(total)
			end)
		end,
	}):start()
end

-- New function to get git status output
local function get_git_status_output(callback)
	local Job = require("plenary.job")
	Job:new({
		command = "git",
		args = { "status", "--porcelain" },
		timeout = 5000,
		on_exit = function(status_job)
			vim.schedule(function()
				callback(status_job:result())
			end)
		end,
		on_stderr = function(_, err_data)
			vim.schedule(function()
				if err_data then notify("Git status error: " .. err_data, vim.log.levels.ERROR) end
			end)
		end
	}):start()
end

-- New function to get unignored untracked files
local function get_unignored_untracked_files(status_output, callback)
	local unignored_files = {}
	local Job = require("plenary.job")
	local untracked_candidates = {}

	for _, line in ipairs(status_output) do
		if line:match("^%?%?") then
			table.insert(untracked_candidates, line:sub(4))
		end
	end

	if #untracked_candidates == 0 then
		callback({})
		return
	end

	local processed_count = 0
	for _, file in ipairs(untracked_candidates) do
		Job:new({
			command = "git",
			args = { "check-ignore", file },
			timeout = 1000,
			on_exit = function(j)
				vim.schedule(function()
					if j.code ~= 0 then
						unignored_files[file] = false
					end
					processed_count = processed_count + 1
					if processed_count == #untracked_candidates then
						callback(unignored_files)
					end
				end)
			end,
		}):start()
	end
end

-- New function to handle the untracked file prompt and actions
local function handle_untracked_file_prompt(next_file, git_root_path, on_choice_done)
	local Job = require("plenary.job")
	M.select_prompt_active = true
	vim.ui.select({ "Add to git", "Add to .gitignore", "Skip", "Skip All" }, {
		prompt = "Untracked file not in .gitignore: " .. next_file,
	}, function(choice)
		if choice == "Add to git" then
			Job:new({
				command = "git",
				args = { "add", next_file },
			}):start()
			debounce_interval = 1000
		elseif choice == "Add to .gitignore" then
			Job:new({
				command = "git",
				args = { "check-ignore", next_file },
				timeout = 1000,
				on_exit = function(j)
					if j.code ~= 0 then
						local current_dir = vim.fn.getcwd()
						local absolute_next_file_path = current_dir .. "/" .. next_file
						local relative_to_git_root_file_path = string.gsub(absolute_next_file_path,
							"^" .. git_root_path .. "/", "")
						Job:new({
							command = "sh",
							args = { "-c", "echo '/" .. relative_to_git_root_file_path .. "' >> " .. git_root_path .. "/.gitignore" },
						}):start()
					end
				end,
			}):start()
			debounce_interval = 1000
		elseif choice == "Skip" then
			debounce_interval = debounce_interval * 2
		else -- Skip All
			debounce_interval = debounce_interval * 2
		end
		M.select_prompt_active = false
		on_choice_done(choice)
	end)
end

-- New function to handle the commit prompt
local function handle_commit_prompt()
	local Job = require("plenary.job")
	M.input_prompt_active = true
	vim.ui.input({
		prompt = "Commit message (or leave empty to skip): ",
	}, function(msg)
		if msg and msg ~= "" then
			Job:new({
				command = "git",
				args = { "add", "." },
				on_exit = function(add_job)
					vim.schedule(function()
						if add_job:result() then
							Job:new({
								command = "git",
								args = { "commit", "-m", msg },
								on_exit = function()
									vim.schedule(function()
										notify("Changes committed!", vim.log.levels.INFO)
									end)
								end,
							}):start()
						else
							notify("Failed to stage changes.", vim.log.levels.ERROR)
						end
					end)
				end,
			}):start()
			debounce_interval = 1000
			M.input_prompt_active = false
		else
			debounce_interval = debounce_interval * 2
			M.input_prompt_active = false
		end
	end)
end

-- Check for uncommitted changes (including untracked files)
local function perform_check_local_changes(git_root_path)
	get_git_status_output(function(status_output)
		if status_output and #status_output > 0 then
			count_changed_lines(function(lines_changed)
				get_unignored_untracked_files(status_output, function(unignored_files)
					local has_untracked = next(unignored_files) ~= nil

					local message = string.format("%d lines changed.", lines_changed)
					if has_untracked then
						message = message .. " Untracked files present."
					end

					local function process_next_file()
						local next_file = nil
						for file, checked in pairs(unignored_files) do
							if not checked then
								next_file = file
								break
							end
						end

						if not next_file then return end

						handle_untracked_file_prompt(next_file, git_root_path, function(choice)
							if choice == "Skip All" then
								for file, _ in pairs(unignored_files) do
									unignored_files[file] = true
								end
							else
								unignored_files[next_file] = true
							end
							if not M.select_prompt_active then
								process_next_file()
							end
						end)
					end

					if not M.select_prompt_active then
						process_next_file()
					end

					if lines_changed > 10 then
						notify(message, vim.log.levels.WARN)
						handle_commit_prompt()
					end
				end)
			end)
		end
	end)
end

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
					perform_check_local_changes(git_root_path)
				else
					notify("Could not determine Git repository root.", vim.log.levels.ERROR)
				end
			end)
		end,
	}):start()
end

-- Toggle watcher on/off
function M.toggle()
	M.enabled = not M.enabled
	notify("Git watcher " .. (M.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

function M.set_log_level(log_level)
	M.min_log_level = log_level
end

function M.reset_interval()
	debounce_interval = 1000
	notify("[GitWatcher] Debounced timer reset to " .. debounce_interval, vim.log.levels.INFO)
end

-- Start filesystem watcher for working directory (Linux: inotifywait, macOS: fswatch)
function M.start_watcher()
	local os_name = vim.loop.os_uname().sysname
	local cmd, args

	if os_name == "Linux" then
		cmd = "inotifywait"
		args = { "-r", "-m", "-e", "modify,create,delete", "--exclude", ".git", "." } -- Watch project root
	elseif os_name == "Darwin" then                                               -- macOS
		cmd = "fswatch"
		args = { "-r", "-x", "." }                                                  -- Watch project root
	else
		-- notify("Unsupported OS for filesystem watcher", vim.log.levels.ERROR)
		return
	end

	local current_debounce_timer = nil -- Variable to hold the active timer object

	-- Define the function reference *once* for debouncing
	local debounced_check = function()
		notify("[GitWatcher] Executing debounced_check", vim.log.levels.DEBUG)
		if current_debounce_timer and current_debounce_timer:is_active() then
			notify("[GitWatcher] Closing existing timer", vim.log.levels.DEBUG)
			current_debounce_timer:stop()
			current_debounce_timer:close()
			current_debounce_timer = nil
		end
		M.check_local_changes()
	end

	local Job = require("plenary.job")
	Job:new({
		command = cmd,
		args = args,
		on_exit = vim.schedule_wrap(function()
			vim.schedule_wrap(function()
				notify("[GitWatcher] Watcher stopped unexpectedly!", vim.log.levels.WARN)
			end)()
		end),
		-- Wrap the entire handler to ensure it runs on the main loop, preventing fast event errors
		on_stdout = vim.schedule_wrap(function(_, data)
			if data then
				notify("[GitWatcher] Filesystem event detected", vim.log.levels.DEBUG)
			end

			-- Cancel existing timer if active
			if current_debounce_timer and current_debounce_timer:is_active() then
				current_debounce_timer:close()
			end

			-- Create new timer with proper cleanup
			current_debounce_timer = vim.defer_fn(function()
				if debounced_check then
					debounced_check()
				end
				current_debounce_timer = nil
			end, debounce_interval)
		end),
	}):start()
end

return M
