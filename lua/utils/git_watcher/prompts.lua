local prompts = {}

function prompts.handle_untracked_file_prompt(
		next_file, git_root_path, on_choice_done, notify_func,
		set_select_prompt_active, set_debounce_interval, get_debounce_interval
)
	local Job = require("plenary.job")
	set_select_prompt_active(true)
	vim.ui.select({ "Add to git", "Add to .gitignore", "Skip", "Skip All" }, {
		prompt = "Untracked file not in .gitignore: " .. next_file,
	}, function(choice)
		if choice == "Add to git" then
			Job:new({
				command = "git",
				args = { "add", next_file },
			}):start()
			set_debounce_interval(INTERVAL)
		elseif choice == "Add to .gitignore" then
			Job:new({
				command = "git",
				args = { "check-ignore", next_file },
				timeout = 1000,
				on_exit = function(j)
					if j.code ~= 0 then
						vim.schedule(function()
							-- TODO: Debug this...
							-- local current_dir = vim.fn.getcwd()
							-- local absolute_next_file_path = current_dir .. "/" .. next_file
							-- notify_func("absolute_next_file_path: " .. absolute_next_file_path)
							-- notify_func("git_root_path: " .. git_root_path)
							-- local relative_to_git_root_file_path = string.gsub(absolute_next_file_path,
							-- 	"^" .. git_root_path .. "/", "")
							Job:new({
								command = "sh",
								args = { "-c", "echo '/" .. next_file .. "' >> " .. git_root_path .. "/.gitignore" },
							}):start()
						end)
					end
				end,
			}):start()
			set_debounce_interval(INTERVAL)
		elseif choice == "Skip" then
			set_debounce_interval(get_debounce_interval() * 2)
		else -- Skip All
			set_debounce_interval(get_debounce_interval() * 2)
		end
		set_select_prompt_active(false)
		on_choice_done(choice)
	end)
end

function prompts.handle_commit_prompt(notify_func, set_input_prompt_active, set_debounce_interval, get_debounce_interval)
	local Job = require("plenary.job")
	local git_utils = require("utils.git_watcher.git_utils") -- Require git_utils here
	set_input_prompt_active(true)
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
										notify_func("Changes committed!", vim.log.levels.INFO)
										git_utils.has_remote(function(has_remote)
											if has_remote then
												vim.ui.select({ "Yes", "No" }, {
													prompt = "Push to remote?",
												}, function(choice)
													if choice == "Yes" then
														Job:new({
															command = "git",
															args = { "push" },
															on_exit = function(push_job)
																vim.schedule(function()
																	if push_job.code == 0 then
																		notify_func("Pushed to remote!", vim.log.levels.INFO)
																	else
																		notify_func("Failed to push to remote.", vim.log.levels.ERROR)
																	end
																end)
															end,
														}):start()
													end
													set_input_prompt_active(false)
												end)
											else
												set_input_prompt_active(false)
											end
										end)
									end)
								end,
							}):start()
						else
							notify_func("Failed to stage changes.", vim.log.levels.ERROR)
							set_input_prompt_active(false)
						end
					end)
				end,
			}):start()
			set_debounce_interval(INTERVAL)
		else
			set_debounce_interval(get_debounce_interval() * 2)
			set_input_prompt_active(false)
		end
	end)
end

return prompts
