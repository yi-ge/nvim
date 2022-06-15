-- https://github.com/neovim/nvim-lspconfig
-- https://github.com/hrsh7th/cmp-nvim-lsp
-- https://github.com/stevearc/aerial.nvim
-- https://github.com/williamboman/nvim-lsp-installer

local icons = require("utils.icons")
local options = require("core.options")
local register_buffer_key = require("core.plugins-mapping")

local M = {
    opt_scrolloff = vim.opt.scrolloff:get(),
}

function M.load_lsp_config()
    M.language_servers_config = {
        -- ltex = require("configure.lsp.ltex"),
        vimls = require("configure.lsp.vimls"),
        sumneko_lua = require("configure.lsp.sumneko_lua"),
        jsonls = require("configure.lsp.jsonls"),
        tailwindcss = require("configure.lsp.tailwindcss"),
        html = require("configure.lsp.html"),
        cssls = require("configure.lsp.cssls"),
        tsserver = require("configure.lsp.tsserver"),
        vuels = require("configure.lsp.vuels"),
        gopls = require("configure.lsp.gopls"),
        pyright = require("configure.lsp.pyright"),
        rust_analyzer = require("configure.lsp.rust"),
    }
end

function M.before() end

function M.load()
    local ok, m = pcall(require, "nvim-lsp-installer")
    if not ok then
        return
    end

    M.nvim_lsp_installer = m

    M.load_lsp_config()
    -- Set options for floating windows
    M.float_style_settings()
    -- Set diagnostic style
    M.diagnostics_style_settings()
    -- Set lspconfig floating border
    M.lspconfig_float_settings()

    M.aerial = require("aerial")
    M.lspconfig = require("lspconfig")
    M.capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

    M.nvim_lsp_installer.setup({
        automatic_installation = true,
        ui = {
            border = "double",
            icons = {
                server_installed = "",
                server_pending = "",
                server_uninstalled = "ﮊ",
            },
            keymaps = {
                toggle_server_expand = "<cr>",
                install_server = "i",
                update_server = "u",
                check_server_version = "c",
                update_all_servers = "U",
                check_outdated_servers = "C",
                uninstall_server = "X",
            },
        },
        github = {
            download_url_template = options.download_source .. "%s/releases/download/%s/%s",
        },
        max_concurrent_installers = 20,
    })
end

function M.after()
    for server_name, server_settings in pairs(M.language_servers_config) do
        local server_available, server = M.nvim_lsp_installer.get_server(server_name)
        -- Determine whether the LSP server is valid (supports automatic download)
        if server_available then
            ---@diagnostic disable-next-line: undefined-field
            if not server:is_installed() then
                -- If the LSP server is not downloaded, download it
                vim.notify("Install Language Server: " .. server_name, "info", { title = "Language Server" })
                ---@diagnostic disable-next-line: undefined-field
                server:install()
            else
                -- If it has been downloaded, it can be used directly
                local lsp_config = server_settings.lsp_config
                local private_attach_callbackfn = server_settings.private_attach_callbackfn
                local public_attach_callbackfn = M.public_attach_callbackfn

                lsp_config.capabilities = M.capabilities

                lsp_config.flags = {
                    debounce_text_changes = 150,
                }
                -- Merge public headers with private headers
                lsp_config.handlers = vim.tbl_deep_extend("force", M.lsp_handlers, lsp_config.handlers or {})
                -- Use the public configuration first, then use the private configuration of each LSP server
                -- If there are duplicates, the private configuration will override the public configuration
                lsp_config.on_attach = function(client, bufnr)
                    public_attach_callbackfn(client, bufnr)
                    private_attach_callbackfn(client, bufnr)
                end

                -- Start LSP server
                M.lspconfig[server_name].setup(lsp_config)
            end
        end
    end
end

function M.float_style_settings()
    -- Add file type for floating window
    M.lsp_handlers = {
        ["textDocument/hover"] = vim.lsp.with(M.lsp_hover, {
            border = "rounded",
            filetype = "lsp-hover",
        }),
        ["textDocument/signatureHelp"] = vim.lsp.with(M.lsp_signature_help, {
            border = "rounded",
            filetype = "lsp-signature-help",
        }),
    }
end

function M.lsp_hover(_, result, ctx, config)
    -- Add file type for LSP hover
    local bufnr, winner = vim.lsp.handlers.hover(_, result, ctx, config)
    if bufnr and winner then
        vim.api.nvim_buf_set_option(bufnr, "filetype", config.filetype)
        return bufnr, winner
    end
end

function M.lsp_signature_help(_, result, ctx, config)
    -- Add file type for LSP signature help
    local bufnr, winner = vim.lsp.handlers.signature_help(_, result, ctx, config)
    if bufnr and winner then
        vim.api.nvim_buf_set_option(bufnr, "filetype", config.filetype)
        return bufnr, winner
    end
end

function M.diagnostics_style_settings()
    vim.diagnostic.config({
        signs = true,
        underline = true,
        severity_sort = true,
        update_in_insert = false,
        float = { source = "always" },
        virtual_text = { prefix = "●", source = "always" },
    })

    for tpe, icon in pairs(icons.diagnostics) do
        local hl = "DiagnosticSign" .. tpe
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
end

function M.lspconfig_float_settings()
    local win = require("lspconfig.ui.windows")
    local _default_opts = win.default_opts

    ---@diagnostic disable-next-line: redefined-local
    win.default_opts = function(options)
        local opts = _default_opts(options)
        opts.border = "double"
        return opts
    end
end

function M.public_attach_callbackfn(client, bufnr)
    M.aerial.on_attach(client, bufnr)
    register_buffer_key(bufnr)
end

return M
