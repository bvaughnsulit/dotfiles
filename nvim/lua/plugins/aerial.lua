local cycle_backend = function()
    local source_buf = vim.b.source_buffer

    local last_val = vim.b[source_buf].aerial_backend
    if last_val ~= nil and last_val == "lsp" then
        vim.b[source_buf].aerial_backend = "treesitter"
    else
        vim.b[source_buf].aerial_backend = "lsp"
    end
    logger("Setting Aerial backend to " .. vim.b[source_buf].aerial_backend)

    require("aerial").refetch_symbols(source_buf)
end

---@module 'lazy'
---@type LazySpec
return {
    {
        "https://github.com/stevearc/aerial.nvim",
        keys = {
            { "<leader>es", "<cmd>AerialToggle<cr>" },
        },
        opts = {
            layout = {
                width = 0.35,
                max_width = 0.5,
            },
            backends = {
                "lsp",
                "treesitter",
                "markdown",
                "asciidoc",
                "man",
            },
            close_automatic_events = { "switch_buffer" },
            icons = require("config.constants").kind_map,
            filter_kind = require("config.constants").kind_filter_base,
            highlight_on_hover = true,
            highlight_on_jump = 300,
            autojump = true,
            close_on_select = true,
            keymaps = {
                ["<a-]>"] = {
                    callback = cycle_backend,
                },
                ["<a-[>"] = {
                    callback = cycle_backend,
                },
            },
        },
    },
}
