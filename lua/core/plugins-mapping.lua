local mapping = require("core.mapping")

local function register_buffer_key(bufnr)
  vim.notify("执行绑定")
  mapping.register({
    {
      mode = { "n" },
      lhs = "<leader>ca",
      rhs = vim.lsp.buf.code_action,
      options = { silent = true, buffer = bufnr },
      description = "Show code action",
    },
    {
      mode = { "n" },
      lhs = "<leader>cn",
      rhs = vim.lsp.buf.rename,
      options = { silent = true, buffer = bufnr },
      description = "Variable renaming",
    },
    {
      mode = { "n" },
      lhs = "<leader>cf",
      rhs = vim.lsp.buf.formatting_sync,
      options = { silent = true, buffer = bufnr },
      description = "Format buffer",
    },
    {
      mode = { "n" },
      lhs = "gI",
      rhs = function()
        require("telescope.builtin").lsp_implementations()
      end,
      options = { silent = true, buffer = bufnr },
      description = "Go to implementations",
    },
    {
      mode = { "n" },
      lhs = "gD",
      rhs = function()
        require("telescope.builtin").lsp_type_definitions()
      end,
      options = { silent = true, buffer = bufnr },
      description = "Go to type definitions",
    },
    {
      mode = { "n" },
      lhs = "gd",
      rhs = function()
        require("telescope.builtin").lsp_definitions()
      end,
      options = { silent = true, buffer = bufnr },
      description = "Go to definitions",
    },
    {
      mode = { "n" },
      lhs = "gr",
      rhs = function()
        require("telescope.builtin").lsp_references()
      end,
      options = { silent = true, buffer = bufnr },
      description = "Go to references",
    },
    {
      mode = { "n" },
      lhs = "gh",
      rhs = vim.lsp.buf.hover,
      options = { silent = true, buffer = bufnr },
      description = "Show help information",
    },
    {
      mode = { "n" },
      lhs = "go",
      rhs = function()
        require("telescope.builtin").diagnostics()
      end,
      options = { silent = true, buffer = bufnr },
      description = "Show Workspace Diagnostics",
    },
    {
      mode = { "n" },
      lhs = "[g",
      rhs = function()
        vim.diagnostic.goto_prev({ float = { border = "rounded" } })
      end,
      options = { silent = true, buffer = bufnr },
      description = "Jump to prev diagnostic",
    },
    {
      mode = { "n" },
      lhs = "]g",
      rhs = function()
        vim.diagnostic.goto_next({ float = { border = "rounded" } })
      end,
      options = { silent = true, buffer = bufnr },
      description = "Jump to next diagnostic",
    },
    {
      mode = { "i" },
      lhs = "<c-j>",
      rhs = function()
        -- When the signature is visible, pressing <c-j> again will close the window
        local wins = vim.api.nvim_list_wins()
        for _, win_id in ipairs(wins) do
          local buf_id = vim.api.nvim_win_get_buf(win_id)
          local ft = vim.api.nvim_buf_get_option(buf_id, "filetype")
          if ft == "lsp-signature-help" then
            vim.api.nvim_win_close(win_id, false)
            return
          end
        end
        vim.lsp.buf.signature_help()
      end,
      options = { silent = true, buffer = bufnr },
      description = "Toggle signature help",
    },
    {
      mode = { "i", "n" },
      lhs = "<c-f>",
      rhs = function()
        local scroll_floating_filetype = { "lsp-signature-help", "lsp-hover" }
        local wins = vim.api.nvim_list_wins()

        for _, win_id in ipairs(wins) do
          local buf_id = vim.api.nvim_win_get_buf(win_id)
          local ft = vim.api.nvim_buf_get_option(buf_id, "filetype")

          if vim.tbl_contains(scroll_floating_filetype, ft) then
            local win_height = vim.api.nvim_win_get_height(win_id)
            local cursor_line = vim.api.nvim_win_get_cursor(win_id)[1]
            local buf_total_line = vim.api.nvim_buf_line_count(buf_id)
            ---@diagnostic disable-next-line: redundant-parameter
            local win_last_line = vim.fn.line("w$", win_id)

            if buf_total_line == win_height then
              vim.api.nvim_echo({ { "Can't scroll down", "MoreMsg" } }, false, {})
              return
            end

            vim.opt.scrolloff = 0
            if cursor_line < win_last_line then
              vim.api.nvim_win_set_cursor(win_id, { win_last_line + 5, 0 })
            elseif cursor_line + 5 > buf_total_line then
              vim.api.nvim_win_set_cursor(win_id, { buf_total_line, 0 })
            else
              vim.api.nvim_win_set_cursor(win_id, { cursor_line + 5, 0 })
            end
            vim.opt.scrolloff = M.opt_scrolloff

            return
          end
        end

        local map = "<c-f>"
        local key = vim.api.nvim_replace_termcodes(map, true, false, true)
        vim.api.nvim_feedkeys(key, "n", true)
      end,
      options = { silent = true, buffer = bufnr },
      description = "Scroll down floating window",
    },
    {
      mode = { "i", "n" },
      lhs = "<c-b>",
      rhs = function()
        local scroll_floating_filetype = { "lsp-signature-help", "lsp-hover" }
        local wins = vim.api.nvim_list_wins()

        for _, win_id in ipairs(wins) do
          local buf_id = vim.api.nvim_win_get_buf(win_id)
          local ft = vim.api.nvim_buf_get_option(buf_id, "filetype")

          if vim.tbl_contains(scroll_floating_filetype, ft) then
            local win_height = vim.api.nvim_win_get_height(win_id)
            local cursor_line = vim.api.nvim_win_get_cursor(win_id)[1]
            local buf_total_line = vim.api.nvim_buf_line_count(buf_id)
            ---@diagnostic disable-next-line: redundant-parameter
            local win_first_line = vim.fn.line("w0", win_id)

            if buf_total_line == win_height then
              vim.api.nvim_echo({ { "Can't scroll up", "MoreMsg" } }, false, {})
              return
            end

            vim.opt.scrolloff = 0
            if cursor_line > win_first_line then
              vim.api.nvim_win_set_cursor(win_id, { win_first_line - 5, 0 })
            elseif cursor_line - 5 < 1 then
              vim.api.nvim_win_set_cursor(win_id, { 1, 0 })
            else
              vim.api.nvim_win_set_cursor(win_id, { cursor_line - 5, 0 })
            end
            vim.opt.scrolloff = M.opt_scrolloff

            return
          end
        end

        local map = "<c-b>"
        local key = vim.api.nvim_replace_termcodes(map, true, false, true)
        vim.api.nvim_feedkeys(key, "n", true)
      end,
      options = { silent = true, buffer = bufnr },
      description = "Scroll up floating window",
    },
  })
end

return register_buffer_key