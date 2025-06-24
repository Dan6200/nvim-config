-- init.lua - Main Neovim configuration entry point

-- Ensure lua directory is discoverable
-- package.path = package.path .. ';' .. vim.fn.stdpath('config') .. '/lua/?.lua'

-- Initialize lazy.nvim package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.notify("Installing lazy.nvim...", vim.log.levels.INFO)
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load core options first
require("options")

-- Load plugins using lazy.nvim
-- The plugin list is defined in lua/plugins.lua
require("lazy").setup(require("plugins"), {
	defaults = {
		lazy = false,   -- Set to true if you want plugins to load lazily by default
		version = "*",  -- Use latest stable versions
		timeout = 3000000 -- 50-minute timeout for plugin operations
	},
	-- Configure checker, UI, performance options etc. here if needed
	-- checker = { enabled = true, notify = false },
	-- performance = { rtp = { disabled_plugins = { ... } } }
})

-- Load remaining configurations after plugins are set up
-- Order might matter depending on dependencies (e.g., keymaps needing plugins)
require("ui")      -- Colorscheme, statusline, transparency
require("keymaps") -- General key mappings
require("utils")   -- Utility functions and commands

-- Configurations loaded via lazy.nvim's `config` function:
-- require("coc_config") -- Loaded by coc.nvim plugin config
-- require("dap_config") -- Loaded by nvim-dap plugin config


-- Optional: Load local/machine-specific settings if they exist
-- local local_settings_path = vim.fn.stdpath('config') .. '/lua/local_settings.lua'
-- local ok, _ = pcall(require, 'local_settings')
-- if ok then
-- else
--   -- Optional: Notify if local settings file is missing but expected
--   -- vim.notify("No local settings file found at " .. local_settings_path, vim.log.levels.INFO)
-- end

-- Git Remote Watcher
local git_watcher = require("utils.git_watcher")
git_watcher.start_watcher()

-- Keymap to toggle:
vim.keymap.set("n", "<leader>gt", git_watcher.toggle)
vim.keymap.set("n", "<leader>gr", git_watcher.reset_interval)
