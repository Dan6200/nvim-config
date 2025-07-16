local notifier = {}

function notifier.setup(min_log_level, native_notify_func)
	local notify = function(msg, level, opts)
		level = level or vim.log.levels.INFO
		if level >= min_log_level then
			native_notify_func(msg, level, opts)
		end
	end
	return notify
end

return notifier
