-- DAP (Debug Adapter Protocol) Configuration

local dap = require "dap"
local dapui = require "dapui"
local widgets = require('dap.ui.widgets')
-- local vscode_dap = require("dap-vscode-js")
local vim = vim

-- --- Language Configurations ---

-- Shared configuration for JavaScript and TypeScript using pwa-node
local shared_js_ts_config = {
	{
		type = "pwa-node",
		request = "launch",
		name = "Debug File (pwa-node)",
		program = "${file}",                            -- Debug the current file
		cwd = "${workspaceFolder}",
		outFiles = { "${workspaceFolder}/dist/**/*.js" }, -- Adjust if your compiled JS is elsewhere
		sourceMaps = true,
		protocol = "inspector",
		console = "integratedTerminal",
		skipFiles = {
			"<node_internals>/**",
			"${workspaceFolder}/node_modules/**",
		},
		resolveSourceMapLocations = { -- Helps find source maps, adjust if needed
			"${workspaceFolder}/**",
			"!**/node_modules/**"
		},
	}
	-- Add more configurations here if needed (e.g., attaching to a running process)
	-- {
	--   type = "pwa-node",
	--   request = "attach",
	--   name = "Attach to Process",
	--   processId = require('dap.utils').pick_process,
	--   cwd = "${workspaceFolder}",
	--   sourceMaps = true,
	--   skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
	-- },
}

-- Assign the shared configuration to relevant filetypes
for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
	dap.configurations[language] = shared_js_ts_config
end

-- --- DAP UI Setup ---
dapui.setup({
	-- layouts = { ... }, -- Customize layout if needed
	-- controls = { ... }, -- Customize controls if needed
	-- floating = { ... }, -- Customize floating window behavior
})

-- --- Keymaps ---
local keyset = vim.keymap.set
local dap_opts = { silent = true }

keyset('n', '<F5>', function() dap.continue() end, dap_opts)
keyset('n', '<F10>', function() dap.step_over() end, dap_opts)
keyset('n', '<F11>', function() dap.step_into() end, dap_opts)
keyset('n', '<F12>', function() dap.step_out() end, dap_opts)
keyset('n', '<Leader>b', function() dap.toggle_breakpoint() end, dap_opts)
keyset('n', '<Leader>B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, dap_opts) -- Allow conditional breakpoints
keyset('n', '<Leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, dap_opts)
keyset('n', '<Leader>dr', function() dap.repl.open() end, dap_opts)
keyset('n', '<Leader>dl', function() dap.run_last() end, dap_opts)

-- DAP UI Keymaps
keyset("n", "<Leader>du", function() dapui.toggle() end, dap_opts)                         -- Toggle DAP UI
keyset("n", "<Leader>de", function() dapui.eval(nil, { enter = true }) end, dap_opts)      -- Evaluate expression under cursor
keyset({ 'n', 'v' }, '<Leader>dh', function() widgets.hover() end, dap_opts)               -- Hover variable
keyset({ 'n', 'v' }, '<Leader>dp', function() widgets.preview() end, dap_opts)             -- Preview variable
keyset('n', '<Leader>df', function() widgets.centered_float(widgets.frames) end, dap_opts) -- Show frames in float
keyset('n', '<Leader>ds', function() widgets.centered_float(widgets.scopes) end, dap_opts) -- Show scopes in float

-- --- Listeners for DAP UI ---
dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

-- --- Adapter Setup ---

-- Ensure the path to vscode-js-debug is correct
local debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"

-- Configure vscode-js-debug adapter using dap-vscode-js helper
-- vscode_dap.setup({
-- 	debugger_path = debugger_path,
-- 	adapters = { "pwa-node", "pwa-chrome", "node-terminal" }, -- Add other adapters if needed
-- 	log_console_level = vim.log.levels.TRACE,
-- })

-- Configure the pwa-node adapter directly
dap.adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "node",
		args = {
			debugger_path .. "/out/src/dapDebugServer.js",
			"${port}",
		},
	}
}

-- --- Virtual Text Setup ---
-- require("nvim-dap-virtual-text").setup({
-- 	-- Customize virtual text options if needed
-- 	-- enabled = true,
-- 	-- highlight_changed_variables = true,
-- 	-- highlight_new_as_changed = false,
-- 	-- show_stop_reason = true,
-- 	-- comment_string = " 💬 ",
-- })
