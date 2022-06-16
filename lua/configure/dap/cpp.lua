local dap = require('dap')
local global = require("core.global")

local extension_path = vim.env.HOME .. '/.vscode/extensions/ms-vscode.cpptools-1.10.7-darwin-arm64'

local cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = extension_path .. '/debugAdapters/bin/OpenDebugAD7'
}

if global.is_windows then
  cppdbg.command = 'C:\\absolute\\path\\to\\cpptools\\extension\\debugAdapters\\bin\\OpenDebugAD7.exe'
  cppdbg.options = {
    detached = false
  }
end

return {
  adapters = {
    cppdbg = cppdbg
  },
  configurations = {
      cs = {
          type = "coreclr",
          name = "launch-netcoredbg",
          request = "launch",
          program = function()
              return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
      },
  },
}
