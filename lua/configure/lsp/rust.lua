local util = require("lspconfig.util")

local M = {}

M.private_attach_callbackfn = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false
end

-- Rust
-- rustup component add rls rust-analysis rust-src
-- Settings: https://github.com/rust-lang/rls#configuration
M.lsp_config = {
    cmd = { "rls" },
    single_file_support = true,
    settings = {
      rust = {
        build_on_save = true,
        all_features = true,
        wait_to_build = 100,
      },
    },
    filetypes = { "rust" },
    root_dir = util.root_pattern("Cargo.toml"),
}

return M
