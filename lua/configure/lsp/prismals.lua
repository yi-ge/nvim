local util = require("lspconfig.util")

local M = {}

M.private_attach_callbackfn = function(client, bufnr)
    -- client.resolved_capabilities.document_formatting = false
    -- client.resolved_capabilities.document_range_formatting = false
end

M.lsp_config = {
    cmd = { "prisma-language-server", "--stdio" },
    single_file_support = true,
    filetypes = { "prisma" },
    root_dir = util.root_pattern(".git", "package.json"),
    settings = {
    prisma = {
            prismaFmtBinPath = ""
        }
    }
}

return M
