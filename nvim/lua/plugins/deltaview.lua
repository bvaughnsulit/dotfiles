local git = require("config.git")

---@module 'lazy'
---@type LazySpec
return {
    "https://github.com/kokusenz/deltaview.nvim",
    dev = true,
    ---@module 'deltaview'
    ---@type DeltaViewOpts
    ---@diagnostic disable: missing-fields
    opts = {
        keyconfig = {
            next_hunk = "]c",
            prev_hunk = "[c",
        },
    },
    ---@diagnostic enable: missing-fields
    cmd = { "DeltaView", "DeltaMenu" },
    keys = {
        {
            "<leader>gd",
            ":DeltaView " .. (git.get_git_base().hash or "") .. "<cr>",
            desc = "Open DeltaView",
        },
    },
}
