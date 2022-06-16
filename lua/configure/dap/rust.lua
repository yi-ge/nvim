-- https://github.com/yi-ge/rust-tools.nvim
local global = require("core.global")

-- Update this path
local extension_path = vim.env.HOME .. '/.vscode/extensions/vadimcn.vscode-lldb-1.7.0/'
local codelldb_path = extension_path .. 'adapter/codelldb'
local liblldb_path = extension_path .. 'lldb/lib/liblldb.' .. (global.is_mac and 'dylib' or 'so')

return {
  adapters = {
    rust = require('rust-tools.dap').get_codelldb_adapter(
      codelldb_path, liblldb_path),
  },
  configurations = {
    rust = {
      {
        name = 'Rust tools debug',
        type = 'rt_lldb',
        request = 'launch',
        program = "${file}",
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
      },
    },
  }
}
