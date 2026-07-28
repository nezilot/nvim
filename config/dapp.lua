local dap = require('dap')
local dapui = require('dapui')

require('dap-go').setup({
  dap_configurations = {
    {
      type = "go",
      name = "Debug (Build Flags)",
      request = "launch",
      program = "${workspaceFolder}", 
      buildFlags = require("dap-go").get_build_flags,
      stopOnEntry = true, -- <--- ЗАСТАВИТ ОТЛАДЧИК ЗАМЕРЕТЬ НА СТАРТЕ
    },
  },
  delve = {
    path = "/home/kitty/go/bin/dlv", -- Твой точный путь к dlv
  },
})

-- === Адаптер для Node.js ===
dap.adapters['pwa-node'] = {
	type = 'server',
	host = 'localhost',
	port = 43229,
	executable = {
		command = 'node',
		args = { '/home/kitty/.local/share/nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js', '43229' },
	},
	options = { detached = false },
}

-- === Конфигурация для запуска JS файлов ===
dap.configurations.javascript = {
	{
		name = "Launch file",
		type = "pwa-node",
		request = "launch",
		program = function()
			local currentFilePath = vim.fn.expand("%")

			return vim.fn.input('Path to executable: ', currentFilePath, 'file')
		end,
		cwd = '${workspaceFolder}',
	},
	{
		name = "Attach to process",
		type = "pwa-node",
		request = "attach",
		port = 43229,
		restart = true,
		cwd = vim.fn.getcwd(),
		sourceMaps = true,
		protocol = 'inspector',
	},
}

dap.configurations.typescript = {
	{
		name = "Launch TS (ts-node)",
		type = "pwa-node",
		request = "launch",
		program = "${file}", -- запускаем текущий TS-файл
		cwd = "${workspaceFolder}",
		runtimeExecutable = "node",
		runtimeArgs = {
			"-r", "ts-node/register", -- регистрация ts-node
			-- Если ты используешь ESM в tsconfig, пиши так:
			-- "--loader", "ts-node/esm",
		},
		sourceMaps = true,
		protocol = "inspector",
		resolveSourceMapLocations = {
			"${workspaceFolder}/**",
			"!**/node_modules/**",
		},
	},

	{
		name = "Attach to Node (TS)",
		type = "pwa-node",
		request = "attach",
		cwd = "${workspaceFolder}",
		port = 9229, -- когда запускаешь node --inspect-brk
		sourceMaps = true,
		protocol = "inspector",
	}
}



-- === Настройка DAP UI ===
dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- === Горячие клавиши ===
local opts = { noremap = true, silent = true }

-- Запустить дебаг
vim.api.nvim_set_keymap('n', '<F5>', ':lua require"dap".continue({ threadId = 1 })<CR>', opts)
-- Шаг в код
vim.api.nvim_set_keymap('n', '<Leader>so', ':lua require"dap".step_over({ threadId = 1 })<CR>', opts)
-- Шаг внутрь функции
vim.api.nvim_set_keymap('n', '<F11>', ':lua require"dap".step_into({ threadId = 1 })<CR>', opts)
-- Шаг из функции
vim.api.nvim_set_keymap('n', '<F12>', ':lua require"dap".step_out({ threadId = 1 })<CR>', opts)
-- Toggle Breakpoint
vim.api.nvim_set_keymap('n', '<Leader>b', ':lua require"dap".toggle_breakpoint()<CR>', opts)
-- Открыть/закрыть UI вручную
vim.api.nvim_set_keymap('n', '<Leader>du', ':lua require"dapui".toggle()<CR>', opts)
