-- Plugin definitions for lazy.nvim

return {
	{ "neoclide/coc.nvim",   config = function() require("coc_config") end }, -- Load CoC config
	{ "dracula/vim",         name = "dracula" },
	{ "joshdick/onedark.vim" },
	{ "Mofiqul/vscode.nvim" },
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 15,
				open_mapping = [[<C-\><C-\>]],
				direction = "horizontal",
				shade_terminals = false,
				start_in_insert = true,
				persist_mode = false,
			})
		end
	},
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function() require("ui") end -- Load UI config which includes lualine setup
	},
	{ "junegunn/fzf",                     build = function() vim.fn['fzf#install']() end },
	{ "ibhagwan/fzf-lua" },
	{ "junegunn/fzf.vim" },
	{ "preservim/nerdtree" },
	-- { "vim-airline/vim-airline" },
	-- { "vim-airline/vim-airline-themes" },
	{ "tpope/vim-obsession" },
	{ "mechatroner/rainbow_csv" },
	{ "mustache/vim-mustache-handlebars", ft = "handlebars" },
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- LSP setup configuration for lua_ls (Lua Language Server)
			require('lspconfig').lua_ls.setup {
				settings = {
					Lua = {
						runtime = {
							version = 'LuaJIT', -- Use LuaJIT runtime for Neovim
						},
						workspace = {
							checkThirdParty = false, -- Disable automatic workspace scanning
							library = {
								vim.api.nvim_get_runtime_file("", true),
							},
						},
						diagnostics = {
							globals = { "vim" }, -- Suppress undefined global warnings
						},
						telemetry = {
							enable = false, -- Disable telemetry for privacy
						},
					},
				},
			}
		end,
	},
	{ "mattn/emmet-vim",    ft = { "html", "css", "javascriptreact", "typescriptreact", "php", "handlebars" } },
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		opts = {
			provider = "deepseek_r1", -- your default provider, can switch later
			vendors = {
				deepseek = {
					__inherited_from = "openai",
					api_key_name = "DEEPSEEK_API_KEY",
					endpoint = "https://api.deepseek.com",
					max_tokens = 8000,
					timeout = 300000,
					model = "deepseek-chat",
				},
				deepseek_r1 = {
					__inherited_from = "openai",
					api_key_name = "DEEPSEEK_API_KEY",
					endpoint = "https://api.deepseek.com",
					timeout = 300000,
					max_tokens = 8000,
					model = "deepseek-reasoner",
					disable_tools = true,
				},
				gemini_lite = {
					__inherited_from = "gemini",
					api_key_name = "GEMINI_API_KEY",
					model = "gemini-2.0-flash-lite",
					max_tokens = 8000,
					timeout = 300000
				},
				gemini2_5 = {
					__inherited_from = "gemini",
					api_key_name = "GEMINI_API_KEY",
					model = "gemini-2.5-pro-preview-03-25",
					max_tokens = 65536,
					timeout = 300000
				},
				gemini2_5_flash = {
					__inherited_from = "gemini",
					api_key_name = "GEMINI_API_KEY",
					model = "gemini-2.5-flash-preview-04-17",
					max_tokens = 65536,
					timeout = 300000,
					disable_tools = false,
				},
				gemini2_5_free = {
					__inherited_from = "gemini",
					api_key_name = "GEMINI_API_KEY",
					model = "gemini-2.5-pro-exp-03-25",
					max_tokens = 65536,
					timeout = 300000,
					disable_tools = false,
				},
			},
			-- file_selector = {
			-- 	provider = "fzf",
			-- 	provider_opts = {
			-- 		get_filepaths = function(params)
			-- 			local cwd = params.cwd
			-- 			local selected_filepaths = params.selected_filepaths
			-- 			local cmd = string.format("fd -H -I --base-directory '%s'", vim.fn.fnameescape(cwd))
			-- 			local output = vim.fn.system(cmd)
			-- 			if vim.v.shell_error ~= 0 then
			-- 				vim.notify("Error running command to get filepaths: " .. cmd, vim.log.levels.ERROR)
			-- 				return {}
			-- 			end
			-- 			local filepaths = vim.split(output, "\n", { trimempty = true })
			-- 			return vim.iter(filepaths)
			-- 					:filter(function(filepath)
			-- 						return not vim.tbl_contains(selected_filepaths, filepath)
			-- 					end)
			-- 					:totable()
			-- 		end,
			-- 	},
			-- },
		},
		build = "make",
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter",
				config = function() require('nvim-treesitter.configs').setup({ highlight = { enable = true } }) end
			},
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			{
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					default = {
						auto = false,
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						use_absolute_path = true,
					},
				},
			},
			{
				'MeanderingProgrammer/render-markdown.nvim',
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
	{ "vuciv/golf" },
	{ "tpope/vim-fugitive" },
	{ "sonph/onehalf",      rtp = "vim" },
	{ "morhetz/gruvbox" },
	{ "sickill/vim-monokai" },
	{ "tomasr/molokai" },
	{ "rakr/vim-one" },
	{
		"mfussenegger/nvim-dap",
		config = function() require("dap_config") end, -- Load DAP config
		dependencies = {
			{
				"microsoft/vscode-js-debug",
				build = "pnpm install --legacy-peer-deps --no-save && pnpx gulp vsDebugServerBundle && rm -rf out && mv dist out",
				version = "1.*",
			},
			{ "mxsdev/nvim-dap-vscode-js" },    -- Configured within dap_config
			{ "rcarriga/nvim-dap-ui" },         -- Configured within dap_config
			{ "theHamsta/nvim-dap-virtual-text" }, -- Configured within dap_config
			"nvim-neotest/nvim-nio",
			"williamboman/mason.nvim",
		},
	},
}
