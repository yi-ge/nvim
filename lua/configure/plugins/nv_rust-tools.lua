-- https://github.com/yi-ge/rust-tools.nvim
local register_buffer_key = require("core.plugins-mapping")
local global              = require("core.global")

local M = {}

function M.before()
end

function M.load()
    local ok, m = pcall(require, "rust-tools")
    if not ok then
        return
    end

    M.rust_tools = m

    local isLoad, n = pcall(require, "nvim-lsp-installer")
    if not isLoad then
        return
    end

    local server_available, server = n.get_server('rust_analyzer')

    if server_available then
      local opts = {
        capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
        flags = {
          debounce_text_changes = 150,
        },
        on_attach = function(client, bufnr)
          -- 禁用格式化功能，交给专门插件插件处理
          client.resolved_capabilities.document_formatting = false
          client.resolved_capabilities.document_range_formatting = false
          -- local function buf_set_keymap(...)
          --   vim.api.nvim_buf_set_keymap(bufnr, ...)
          -- end
          -- -- 绑定快捷键
          -- require("keybindings").mapLSP(buf_set_keymap)
          register_buffer_key(bufnr)
        end,
      }

      -- Update this path
      local extension_path = vim.env.HOME .. '/.vscode/extensions/vadimcn.vscode-lldb-1.7.0/'
      local codelldb_path = extension_path .. 'adapter/codelldb'
      local liblldb_path = extension_path .. 'lldb/lib/liblldb.' .. (global.is_mac and 'dylib' or 'so')

      M.rust_tools.setup({
        -- The "server" property provided in rust-tools setup function are the
        -- settings rust-tools will provide to lspconfig during init.
        -- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
        -- with the user's own settings (opts).
        server = vim.tbl_deep_extend("force", server:get_default_options(), opts),
        dap = {
          adapter = require('rust-tools.dap').get_codelldb_adapter(
              codelldb_path, liblldb_path)
        }
      })

      server:attach_buffers()
      -- Only if standalone support is needed
      M.rust_tools.start_standalone_if_required()
    end
end

function M.after()
end

return M
