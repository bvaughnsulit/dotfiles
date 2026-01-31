local git = require("config.git")

---@module 'lazy'
---@type LazySpec
return {
    "https://github.com/kokusenz/deltaview.nvim",
    dev = true,
    opts = {},
    cmd = { "DeltaView", "DeltaMenu" },
    keys = {
        {
            "<leader>gd",
            ":DeltaView " .. (git.get_git_base().hash or "") .. "<cr>",
            desc = "Open DeltaView",
        },
    },
}
