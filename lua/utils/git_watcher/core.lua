local core = {}

function core.perform_check_local_changes(git_root_path, git_utils, prompts, notify_func, get_select_prompt_active,
																					set_select_prompt_active, set_input_prompt_active, set_debounce_interval,
																					get_debounce_interval)
	git_utils.get_git_status_output(function(status_output)
		if status_output and #status_output > 0 then
			git_utils.count_changed_lines(function(lines_changed)
				git_utils.get_unignored_untracked_files(status_output, function(unignored_files)
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

						prompts.handle_untracked_file_prompt(next_file, git_root_path, function(choice)
							if choice == "Skip All" then
								for file, _ in pairs(unignored_files) do
									unignored_files[file] = true
								end
							else
								unignored_files[next_file] = true
							end
							if not get_select_prompt_active() then
								process_next_file()
							end
						end, notify_func, set_select_prompt_active, set_debounce_interval, get_debounce_interval)
					end

					if not get_select_prompt_active() then
						process_next_file()
					end

					if lines_changed > 10 then
						notify_func(message, vim.log.levels.WARN)
						prompts.handle_commit_prompt(notify_func, set_input_prompt_active, set_debounce_interval,
							get_debounce_interval)
					end
				end)
			end)
		end
	end, notify_func)
end

return core
