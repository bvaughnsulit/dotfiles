return {
    {
        "pwntester/octo.nvim",
        cmd = "Octo",
        ---@diagnostic disable: missing-fields
        ---@module "octo"
        ---@type OctoConfig
        opts = {
            picker = "snacks",
            picker_config = {
                snacks = {
                    actions = {
                        pull_requests = {
                            {
                                name = "merge_pr",
                                fn = function() end,
                                lhs = "<C-r>",
                                mode = { "n", "i" },
                                desc = "noop",
                            },
                            {
                                name = "noop",
                                fn = function() end,
                                lhs = "<C-r>",
                                mode = { "n", "i" },
                                desc = "noop",
                            },
                        },
                    },
                },
            },
            mappings_disable_default = true,
        },
        ---@diagnostic enable: missing-fields
        keys = {
            { "<leader>gG", "<cmd>:Octo actions<cr>", desc = "Open Octo" },
            { "<leader>gs", "<cmd>:Octo pr list states=OPEN<cr>", desc = "Search Open PRs" },
        },
    },
}
