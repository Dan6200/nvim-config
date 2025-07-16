local prompts = {}

function prompts.handle_untracked_file_prompt(next_file, git_root_path, on_choice_done, notify_func,
																							set_select_prompt_active, set_debounce_interval, get_debounce_interval)
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
			set_debounce_interval(1000)
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
			set_debounce_interval(1000)
		elseif choice == "Skip" then
			set_debounce_interval(get_debounce_interval() * 2)
		else     -- Skip All
			set_debounce_interval(get_debounce_interval() * 2)
		end
		set_select_prompt_active(false)
		on_choice_done(choice)
	end)
end

function prompts.handle_commit_prompt(notify_func, set_input_prompt_active, set_debounce_interval, get_debounce_interval)
	local Job = require("plenary.job")
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
									end)
								end,
							}):start()
						else
							notify_func("Failed to stage changes.", vim.log.levels.ERROR)
						end
					end)
				end,
			}):start()
			set_debounce_interval(1000)
			set_input_prompt_active(false)
		else
			set_debounce_interval(get_debounce_interval() * 2)
			set_input_prompt_active(false)
		end
	end)
end

return prompts
