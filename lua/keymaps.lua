-- Global key mappings

local keyset = vim.keymap.set
local opts_noremap_silent = { noremap = true, silent = true }

-- General Mappings
keyset('n', '[q', 'o<ESC>o<ESC>', opts_noremap_silent) -- Add empty lines above/below
keyset('n', ']q', 'O<ESC>O<ESC>', opts_noremap_silent)
keyset('n', '[a', ':w<CR>', opts_noremap_silent)       -- Quick save
keyset('n', '-', '@:', opts_noremap_silent)            -- Repeat last command-line command

-- Buffer Navigation
keyset('n', '<C-J>', ':bn<CR>', opts_noremap_silent) -- Next buffer
keyset('n', '<C-K>', ':bp<CR>', opts_noremap_silent) -- Previous buffer

-- Quickfix List Navigation
keyset('n', '[f', ':cn<CR>', opts_noremap_silent) -- Next quickfix item
keyset('n', ']f', ':cp<CR>', opts_noremap_silent) -- Previous quickfix item

-- FZF Mappings
keyset('n', '<space>b', ':Buffers<CR>', opts_noremap_silent)        -- FZF Buffers
keyset('n', '<space>l', ':Lines<CR>', opts_noremap_silent)          -- FZF Lines in current buffer
keyset('n', '<space>f', ':Files<CR>', opts_noremap_silent)          -- FZF Files in CWD
keyset('n', '<space>h', ':History<CR>', opts_noremap_silent)        -- FZF Command History
keyset('n', '<space>g', ':GFiles<CR>', opts_noremap_silent)         -- FZF Git Files
keyset('n', '<space>G', ':GFiles?<CR>', opts_noremap_silent)        -- FZF Git Status
keyset('n', '[r', ':Rg<CR>', opts_noremap_silent)                   -- FZF Ripgrep in CWD
keyset('n', ']r', ':RG<CR>', opts_noremap_silent)                   -- FZF Ripgrep globally (respect .gitignore)
keyset('n', '<leader>r', ':Rg <C-R><C-W><CR>', opts_noremap_silent) -- FZF Ripgrep for word under cursor

-- Change Directory Mappings (using FZF)
keyset('n', '<leader>c',
	":call fzf#run({'source': 'fd -Ht d --no-ignore', 'sink': 'cd', 'window':{'width':0.9, 'height':0.6}})<CR>",
	opts_noremap_silent) -- CD into subdir of CWD
keyset('n', '<leader>C',
	":call fzf#run({'source': 'find ~ -type d -print', 'sink': 'cd', 'window':{'width':0.9, 'height':0.6}})<CR>",
	opts_noremap_silent)                                         -- CD into any dir under ~
keyset('n', '<leader>cwd', ':cd %:h<CR>', opts_noremap_silent) -- CD to current file's directory

-- File Operations
keyset('n', '<leader>f',
	":call fzf#run({'source': 'fd -Ht f --no-ignore', 'sink': 'e', 'window':{'width':0.9, 'height':0.6}})<CR>",
	opts_noremap_silent)                                             -- Edit file in CWD
keyset('n', '<leader>fx', ':!chmod +x %<CR>', opts_noremap_silent) -- Make current file executable

-- Search and Replace
keyset('v', '//', 'y/\\V<C-R>=escape(@",\'/\\\')<CR><CR>', opts_noremap_silent) -- Search for visual selection

-- Navigation
keyset('n', 'ge', 'ge', {}) -- Keep default `ge` behavior (go to end of previous word)

-- Vimgrep
keyset('n', '<space>V', ':Vimgrep ', { noremap = true }) -- Start Vimgrep search

-- Git Mappings
keyset('n', ')P', ':Git push<CR>', opts_noremap_silent)
keyset('n', '(O', ':Git add . | :Git commit --verbose<CR>', opts_noremap_silent)
keyset('n', '<Space>C', ':Commits<CR>', opts_noremap_silent) -- FZF Git Commits

-- Command Line
keyset('n', '::', 'q:', opts_noremap_silent) -- Open command-line window

-- Jumplist improvement for j/k
keyset('n', 'k', "(v:count > 1 ? \"m'\" . v:count : '') . 'k'", { expr = true, silent = true })
keyset('n', 'j', "(v:count > 1 ? \"m'\" . v:count : '') . 'j'", { expr = true, silent = true })

-- NERDTree Mappings
keyset('n', '<C-n><C-n>', ':NERDTreeToggle<CR>', opts_noremap_silent)
keyset('n', '<C-n>', ':NERDTreeFocus<CR>', opts_noremap_silent)
keyset('n', '<C-n><C-k>', ':NERDTreeFind<CR>', opts_noremap_silent)
keyset('n', '<C-n><C-l>', ':NERDTreeRefreshRoot<CR>', opts_noremap_silent)
-- Disable '?' remap
vim.api.nvim_create_autocmd("FileType", {
	pattern = "nerdtree",
	callback = function()
		-- Map '?' to standard backwards search (requires NERDTree to not override it)
		vim.keymap.set('n', '?', [[?]], { buffer = true, remap = true })
	end,
})
-- Note: NERDTree global map vars (like g:NERDTreeMapHelp) are set in ui.lua or directly in init.lua if preferred

-- Yank/Paste/Delete All
keyset("n", "<C-a>", "ggVG", opts_noremap_silent)     -- Select all
keyset("n", "<C-y>", ":%y+<CR>", opts_noremap_silent) -- Yank all to system clipboard
keyset("n", "<C-p>", "\"+P", opts_noremap_silent)     -- Paste from system clipboard (normal mode)
keyset("v", "<C-p>", "\"+P", opts_noremap_silent)     -- Paste from system clipboard (visual mode)
keyset("n", "<C-x>", ":%d+<CR>", opts_noremap_silent) -- Delete all and copy to system clipboard

-- Make command mapping
keyset('n', '<leader>q', ':make all<CR>', opts_noremap_silent)
keyset('n', '<leader>w', ':make build<CR>', opts_noremap_silent)
keyset('n', '<leader>e', ':make test<CR>', opts_noremap_silent)

-- Close floating popups (useful for LSP/CoC popups)
keyset('n', '<Esc><Esc>', require('utils').close_floating_popup, opts_noremap_silent)

-- Remap <C-h> to <C-w>
keyset('i', '<C-h>', '<C-w>', opts_noremap_silent)

-- [ motions to be more practical
keyset('n', ']]', '/{<CR>', opts_noremap_silent)
keyset('n', '[[', '?{<CR>', opts_noremap_silent)
keyset('n', '][', '/}<CR>', opts_noremap_silent)
keyset('n', '[]', '?{<CR>', opts_noremap_silent)
