-- Utility functions and commands

local M = {}

-- Function to close floating popups (like CoC or LSP hover/signature help)
function M.close_floating_popup()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local config = vim.api.nvim_win_get_config(win)
		-- Check if it's a floating window
		if config.relative ~= "" and config.external == false then
			-- More specific checks can be added here if needed,
			-- e.g., checking buffer name or filetype associated with the window
			pcall(vim.api.nvim_win_close, win, true) -- Use pcall to ignore errors if window is already closed
		end
	end
end

-- Command for quicker vimgrep searches
vim.api.nvim_create_user_command('Vimgrep', 'vimgrep /<args>/ **/*',
	{ nargs = 1, desc = "Vimgrep in all files recursively" })

-- Autocommand for setting compiler and makeprg for TypeScript
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "typescript", "typescriptreact" },
	desc = "Set compiler and makeprg for TypeScript",
	callback = function()
		vim.cmd("compiler tsc")      -- Set tsc-style errorformat
		vim.opt_local.makeprg = "make" -- Run make instead of tsc directly (adjust if you use `tsc` directly)
	end,
})


return M
