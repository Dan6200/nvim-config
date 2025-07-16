local watcher = {}

function watcher.start_watcher(notify_func, check_local_changes_func, get_debounce_interval)
	local os_name = vim.loop.os_uname().sysname
	local cmd, args

	if os_name == "Linux" then
		cmd = "inotifywait"
		args = { "-r", "-m", "-e", "modify,create,delete", "--exclude", ".git", "." }     -- Watch project root
	elseif os_name == "Darwin" then                                                     -- macOS
		cmd = "fswatch"
		args = { "-r", "-x", "." }                                                        -- Watch project root
	else
		-- notify("Unsupported OS for filesystem watcher", vim.log.levels.ERROR)
		return
	end

	local current_debounce_timer = nil   -- Variable to hold the active timer object

	-- Define the function reference *once* for debouncing
	local debounced_check = function()
		notify_func("[GitWatcher] Executing debounced_check", vim.log.levels.DEBUG)
		if current_debounce_timer and current_debounce_timer:is_active() then
			notify_func("[GitWatcher] Closing existing timer", vim.log.levels.DEBUG)
			current_debounce_timer:stop()
			current_debounce_timer:close()
			current_debounce_timer = nil
		end
		check_local_changes_func()
	end

	local Job = require("plenary.job")
	Job:new({
		command = cmd,
		args = args,
		on_exit = vim.schedule_wrap(function()
			vim.schedule_wrap(function()
				notify_func("[GitWatcher] Watcher stopped unexpectedly!", vim.log.levels.WARN)
			end)()
		end),
		-- Wrap the entire handler to ensure it runs on the main loop, preventing fast event errors
		on_stdout = vim.schedule_wrap(function(_, data)
			if data then
				notify_func("[GitWatcher] Filesystem event detected", vim.log.levels.DEBUG)
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
			end, get_debounce_interval())
		end),
	}):start()
end

return watcher
