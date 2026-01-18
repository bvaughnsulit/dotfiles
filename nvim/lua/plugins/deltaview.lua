local git = require("config.git")

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
