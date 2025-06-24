-- Core Neovim options

vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.hlsearch = false      -- Don't highlight search results permanently
vim.opt.incsearch = true      -- Show search results incrementally
vim.opt.shiftwidth = 2        -- Number of spaces for indentation
vim.opt.tabstop = 2           -- Number of spaces a tab counts for
vim.opt.backup = false        -- No backup files
vim.opt.writebackup = false   -- No backup files during write
vim.opt.updatetime = 300      -- Faster update time for CursorHold events
vim.opt.signcolumn = "yes"    -- Always show the sign column

-- Set leader key
vim.g.mapleader = '\\'
