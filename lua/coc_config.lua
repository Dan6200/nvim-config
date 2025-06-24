-- CoC (Conqueror of Completion) Configuration

local keyset = vim.keymap.set
local coc_opts_silent = { silent = true }
local coc_opts_silent_noremap = { silent = true, noremap = true }
local coc_opts_silent_noremap_expr = { silent = true, noremap = true, expr = true, replace_keycodes = false }
local coc_opts_silent_nowait = { silent = true, nowait = true }
local coc_opts_silent_nowait_expr = { silent = true, nowait = true, expr = true }

-- --- Helper Functions ---

-- Check if cursor is at the beginning of the line or preceded by whitespace
function _G.check_back_space()
	local col = vim.fn.col('.') - 1
	return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Show documentation for word under cursor
function _G.show_docs()
	local cw = vim.fn.expand('<cword>')
	if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
		vim.api.nvim_command('h ' .. cw)
	elseif vim.api.nvim_eval('coc#rpc#ready()') then
		vim.fn.CocActionAsync('doHover')
	else
		vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
	end
end

-- --- Keymaps ---

-- Autocomplete Mappings
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
	coc_opts_silent_noremap_expr)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], coc_opts_silent_noremap_expr)
-- Messes up command-line window (q:)...
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]],
	coc_opts_silent_noremap_expr)
-- keyset('i', '<CR>', '<C-g>u<CR>', coc_opts_silent_noremap)
keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)", coc_opts_silent) -- Trigger snippets
keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true }) -- Trigger completion

-- Diagnostics Navigation
keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", coc_opts_silent)
keyset("n", "]g", "<Plug>(coc-diagnostic-next)", coc_opts_silent)

-- Code Navigation (Go To...)
keyset("n", "gd", "<Plug>(coc-definition)", coc_opts_silent)
keyset("n", "gy", "<Plug>(coc-type-definition)", coc_opts_silent)
keyset("n", "gi", "<Plug>(coc-implementation)", coc_opts_silent)
keyset("n", "gr", "<Plug>(coc-references)", coc_opts_silent)

-- Documentation
keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', coc_opts_silent)
keyset("n", "<space>k", [[k]], coc_opts_silent)

-- Symbol Renaming
keyset("n", "<leader>rn", "<Plug>(coc-rename)", coc_opts_silent)

-- Formatting
keyset("x", "<leader>f", "<Plug>(coc-format-selected)", coc_opts_silent)
keyset("n", "<leader>f", "<Plug>(coc-format-selected)", coc_opts_silent)

-- Code Actions
keyset("x", "<leader>d", "<Plug>(coc-codeaction-selected)", coc_opts_silent_nowait)
keyset("n", "<leader>d", "<Plug>(coc-codeaction-selected)", coc_opts_silent_nowait)
keyset("n", "<leader>dc", "<Plug>(coc-codeaction-cursor)", coc_opts_silent_nowait) -- Code action at cursor
keyset("n", "<leader>ds", "<Plug>(coc-codeaction-source)", coc_opts_silent_nowait) -- Source code actions for file
keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", coc_opts_silent_nowait)       -- Apply preferred quickfix

-- Refactoring Actions
keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", coc_opts_silent)
keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", coc_opts_silent)
keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", coc_opts_silent)

-- Code Lens
keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", coc_opts_silent_nowait)

-- Text Objects (Function and Class)
keyset("x", "if", "<Plug>(coc-funcobj-i)", coc_opts_silent_nowait)
keyset("o", "if", "<Plug>(coc-funcobj-i)", coc_opts_silent_nowait)
keyset("x", "af", "<Plug>(coc-funcobj-a)", coc_opts_silent_nowait)
keyset("o", "af", "<Plug>(coc-funcobj-a)", coc_opts_silent_nowait)
keyset("x", "ic", "<Plug>(coc-classobj-i)", coc_opts_silent_nowait)
keyset("o", "ic", "<Plug>(coc-classobj-i)", coc_opts_silent_nowait)
keyset("x", "ac", "<Plug>(coc-classobj-a)", coc_opts_silent_nowait)
keyset("o", "ac", "<Plug>(coc-classobj-a)", coc_opts_silent_nowait)

-- Float Window Scrolling
keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', coc_opts_silent_nowait_expr)
keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', coc_opts_silent_nowait_expr)
keyset("i", "<C-f>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', coc_opts_silent_nowait_expr)
keyset("i", "<C-b>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', coc_opts_silent_nowait_expr)
keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', coc_opts_silent_nowait_expr)
keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', coc_opts_silent_nowait_expr)

-- Selection Range
keyset("n", "<C-s>", "<Plug>(coc-range-select)", coc_opts_silent)
keyset("x", "<C-s>", "<Plug>(coc-range-select)", coc_opts_silent)

-- CoC List Mappings
keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", coc_opts_silent_nowait) -- Show diagnostics list
keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", coc_opts_silent_nowait)  -- Manage extensions
keyset("n", "<space>c", ":<C-u>CocList commands<cr>", coc_opts_silent_nowait)    -- Show commands
keyset("n", "<space>o", ":<C-u>CocList outline<cr>", coc_opts_silent_nowait)     -- Show document outline
keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", coc_opts_silent_nowait)  -- Search workspace symbols
keyset("n", "<space>j", ":<C-u>CocNext<cr>", coc_opts_silent_nowait)             -- Go to next item in list
keyset("n", "<space>k", ":<C-u>CocPrev<cr>", coc_opts_silent_nowait)             -- Go to previous item in list
keyset("n", "<space>p", ":<C-u>CocListResume<cr>", coc_opts_silent_nowait)       -- Resume last list

-- --- Autocommands ---
local coc_augroup = vim.api.nvim_create_augroup("CocGroup", { clear = true })

-- Highlight symbol references on CursorHold
vim.api.nvim_create_autocmd("CursorHold", {
	group = coc_augroup,
	command = "silent call CocActionAsync('highlight')",
	desc = "Highlight symbol under cursor on CursorHold"
})

-- Set formatexpr for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = coc_augroup,
	pattern = "typescript,json,javascript,typescriptreact,javascriptreact", -- Added JS types
	command = "setl formatexpr=CocAction('formatSelected')",
	desc = "Setup formatexpr for relevant filetypes."
})

-- Update signature help on jumping to placeholder
vim.api.nvim_create_autocmd("User", {
	group = coc_augroup,
	pattern = "CocJumpPlaceholder",
	command = "call CocActionAsync('showSignatureHelp')",
	desc = "Update signature help on jump placeholder"
})

-- --- Commands ---
vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})
vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", { nargs = '?' })
vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {}) -- Organize Imports

-- Coc.nvim enable/disble/restart
keyset('n', '<leader>ce', ':CocEnable<CR>', coc_opts_silent_noremap)
keyset('n', '<leader>cr', ':CocRestart<CR>', coc_opts_silent_noremap)
keyset('n', '<leader>cw', ':CocDisable<CR>', coc_opts_silent_noremap)
