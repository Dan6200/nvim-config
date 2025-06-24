local M = {}
-- Global toggle to disable watcher temporarily
M.enabled = true

local vim = vim
local debounce_interval = 10000
M.min_log_level = vim.log.levels.WARN
local native_notify = vim.notify or vim.notify_once


-- Improved notification system with rate limiting
local notify = function(msg, level, opts)
	level = level or vim.log.levels.INFO
	if level >= M.min_log_level then
		native_notify(msg, level, opts)
		-- Prevent duplicate notifications within 5 seconds: Try this AI suggestion later
		-- local now = vim.loop.now()
		-- if not last_notification[msg] or (now - last_notification[msg] > 5000) then
		-- 	native_notify(msg, level, opts)
		-- 	last_notification[msg] = now
		-- end
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
			-- Schedule the final callback onto the main loop
			vim.schedule(function()
				callback(total)
			end)
		end,
	}):start()
end

-- Check for uncommitted changes (including untracked files)
function M.check_local_changes()
	if not M.enabled or M.select_prompt_active then return end

	-- Reset unignored files tracking for new check
	unignored_files = {}
	M.select_prompt_active = false -- Track if we have an active prompt

	local Job = require("plenary.job")

	-- Use git status --porcelain to check for any changes (modified, deleted, untracked, etc.)
	Job:new({
		command = "git",
		args = { "status", "--porcelain" },
		timeout = 5000, -- Short timeout, status should be fast
		-- Schedule the on_exit handler to run on the main loop
		on_exit = function(status_job)
			vim.schedule(function()
				local status_output = status_job:result()
				-- Check if there's any output (any line indicates a change)
				if status_output and #status_output > 0 then
					-- Changes detected, now get line count for notification and prompt
					count_changed_lines(function(lines_changed)
						-- Check if untracked files exist for a more informative message
						local has_untracked = false
						for _, line in ipairs(status_output) do
							if line:match("^%?%?") then
								has_untracked = true
								break
							end
						end

						local message = string.format("%d lines changed.", lines_changed)
						if has_untracked then
							message = message .. " Untracked files present."

							-- Check if any untracked files are not in .gitignore
							for _, line in ipairs(status_output) do
								if line:match("^%?%?") then
									local file = line:sub(4)
									-- Check if file is ignored
									local job = Job:new({
										command = "git",
										args = { "check-ignore", file },
										timeout = 1000,
									})
									job:sync()
									if job:result() == nil or #job:result() == 0 then
										if not unignored_files[file] then
											unignored_files[file] = false
										end
									end
								else
									unignored_files = {}
								end
							end
						end

						-- Process files one by one using a queue
						local function process_next_file()
							-- Find next unprocessed file
							local next_file = nil
							for file, checked in pairs(unignored_files) do
								if not checked then
									next_file = file
									break
								end
							end

							if not next_file then return end -- No more files to process

							M.select_prompt_active = true
							vim.ui.select({ "Add to git", "Add to .gitignore", "Skip" }, {
								prompt = "Untracked file not in .gitignore: " .. next_file,
							}, function(choice)
								if choice == "Add to git" then
									Job:new({
										command = "git",
										args = { "add", next_file },
									}):start()
									unignored_files[next_file] = true
								elseif choice == "Add to .gitignore" then
									-- Check if already in .gitignore
									Job:new({
										command = "git",
										args = { "check-ignore", next_file },
										timeout = 1000,
										on_exit = function(j)
											if j.code ~= 0 then -- Not ignored yet
												Job:new({
													command = "sh",
													args = { "-c", "echo '/" .. next_file .. "' >> .gitignore" },
												}):start()
											end
										end,
									}):start()
									unignored_files[next_file] = true
								else
									-- Skip but don't mark as processed
									debounce_interval = debounce_interval * 10
								end

								M.select_prompt_active = false
								process_next_file() -- Process next file after response
							end)
						end

						-- Start processing if no active prompt
						if not M.select_prompt_active then
							process_next_file()
						end

						-- Only prompt if significant changes or untracked files exist
						-- Adjust threshold as needed
						if lines_changed > 150 then
							-- Already running in vim.schedule, no need to wrap again
							notify(message, vim.log.levels.WARN)

							vim.ui.input({
								prompt = "Commit message (or leave empty to skip): ",
							}, function(msg)
								if msg and msg ~= "" then
									-- Stage all changes (including untracked) before committing
									Job:new({
										command = "git",
										args = { "add", "." },
										-- Schedule the on_exit handler to run on the main loop
										on_exit = function(add_job)
											vim.schedule(function()
												if add_job:result() then -- Check if add was successful (basic check)
													Job:new({
														command = "git",
														args = { "commit", "-m", msg },
														-- Schedule the on_exit handler to run on the main loop
														on_exit = function()
															vim.schedule(function()
																notify("Changes committed!", vim.log.levels.INFO)
															end)
														end,
													}):start()
												else
													-- Already running in vim.schedule, no need to wrap again
													notify("Failed to stage changes.", vim.log.levels.ERROR)
												end
											end) -- End of vim.schedule for git add
										end, -- End of on_exit function for git add
									}):start()
									debounce_interval = 10000
								else
									debounce_interval = debounce_interval * 10
								end
							end)
						end
					end)
				end -- End of if status_output
			end) -- End of vim.schedule for git status
		end, -- End of on_exit function for git status
		-- Optional: Add on_stderr for git status errors
		-- on_stderr = function(_, err_data)
		--   vim.schedule(function()
		--     if err_data then notify("Git status error: " .. err_data, vim.log.levels.ERROR) end
		--   end)
		-- end
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
