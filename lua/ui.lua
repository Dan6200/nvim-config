-- UI Configuration: Colorscheme, Lualine, Airline, Transparency

-- Set colorscheme
vim.cmd("colorscheme vscode")

-- Lualine setup
require('lualine').setup({
	options = {
		theme = 'vscode',
		-- icons_enabled = true, -- Ensure you have a nerd font installed
		-- component_separators = { left = '', right = ''},
		-- section_separators = { left = '', right = ''},
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		}
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = { 'branch', 'diff', 'diagnostics' },
		lualine_c = { 'filename' },
		lualine_x = { 'encoding', 'fileformat', 'filetype' },
		lualine_y = { 'progress' },
		lualine_z = { 'location' }
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { 'filename' },
		lualine_x = { 'location' },
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {}
})

-- Airline Configuration (if still used alongside Lualine, otherwise remove)
-- vim.g.airline_theme = 'vscode' -- Or another theme
vim.g.airline_powerline_fonts = 1 -- Use Powerline symbols if font supports it

if not vim.g.airline_symbols then vim.g.airline_symbols = {} end

-- Powerline symbols (ensure your font supports these)
vim.g.airline_left_sep = ''
vim.g.airline_left_alt_sep = ''
vim.g.airline_right_sep = ''
vim.g.airline_right_alt_sep = ''
vim.g.airline_symbols.branch = ''
vim.g.airline_symbols.readonly = ''
vim.g.airline_symbols.linenr = ''
vim.g.airline_symbols.maxlinenr = '☰'
vim.g.airline_symbols.dirty = '⚡'

-- Optional: Unicode symbols as fallback or alternative
-- vim.g.airline_left_sep = '▶'
-- vim.g.airline_right_sep = '◀'
-- vim.g.airline_symbols.colnr = '℅:'
-- vim.g.airline_symbols.crypt = '🔒'
-- vim.g.airline_symbols.linenr = '¶'
-- vim.g.airline_symbols.branch = '⎇'
-- vim.g.airline_symbols.paste = 'ρ'
-- vim.g.airline_symbols.spell = 'Ꞩ'
-- vim.g.airline_symbols.notexists = 'Ɇ'
-- vim.g.airline_symbols.whitespace = 'Ξ'

-- Enable tabline extension if desired (Lualine might handle this better)
-- vim.g["airline#extensions#tabline#enabled"] = 1
-- vim.g["airline#extensions#tabline#left_sep"] = ''
-- vim.g["airline#extensions#tabline#left_alt_sep"] = ''
-- vim.g["airline#extensions#tabline#right_sep"] = ''
-- vim.g["airline#extensions#tabline#right_alt_sep"] = ''

-- Transparency Settings
vim.api.nvim_set_hl(0, "Normal", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "LineNr", { bg = "none", ctermbg = "none", fg = "#5a5a5a" }) -- Keep foreground for visibility
vim.api.nvim_set_hl(0, "FoldColumn", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "Folded", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none", ctermbg = "none" }) -- Hide the `~` symbols
-- Add other groups as needed, e.g., Telescope, NvimTree backgrounds

-- Dracula theme customization (if using Dracula)
-- vim.g.dracula_bold = 1
-- vim.g.dracula_italic = 1 -- Enable italics if desired
-- vim.g.dracula_full_special_attrs_support = 1

-- NERDTree Global Variables (can also go in options.lua or init.lua)
vim.g.NERDTreeMapHelp = '<F2>'
vim.g.NERDTreeMapQuit = '<F12>'
vim.g.NERDTreeMapJumpNextSibling = '<C-n>'
vim.g.NERDTreeMapJumpPrevSibling = '<C-p>'
