local git_utils = {}

function git_utils.count_changed_lines(callback)
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

function git_utils.get_git_status_output(callback, notify_func)
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
				if err_data then notify_func("Git status error: " .. err_data, vim.log.levels.ERROR) end
			end)
		end
	}):start()
end

function git_utils.get_unignored_untracked_files(status_output, callback)
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

function git_utils.has_remote(callback)
	local Job = require("plenary.job")
	Job:new({
		command = "git",
		args = { "remote" },
		timeout = 5000,
		on_exit = function(j)
			vim.schedule(function()
				callback(#j:result() > 0)
			end)
		end,
	}):start()
end

return git_utils
