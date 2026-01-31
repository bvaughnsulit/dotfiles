local utils = require("config.utils")

---@type LazySpec
return {
    {
        "https://github.com/pwntester/octo.nvim",
        cmd = "Octo",
        opts = function()
            ---@diagnostic disable: missing-fields
            ---@module "octo"
            ---@type OctoConfig
            local opts = {
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
            }

            vim.api.nvim_create_autocmd("BufModifiedSet", {
                pattern = { "octo://*" },
                group = utils.augroup("octo_buf"),
                callback = function(event)
                    if not vim.bo[event.buf].modified then
                        vim.bo.modifiable = false
                        vim.schedule(function()
                            vim.keymap.set("n", "<leader>E", function() vim.bo.modifiable = true end, {
                                buffer = event.buf,
                                silent = true,
                                desc = "Enable editing",
                            })
                        end)
                    end
                end,
                desc = "Disable editing on octo buffers by default",
            })

            return opts
        end,
        ---@diagnostic enable: missing-fields
        ---
        keys = {
            { "<leader>Gg", "<cmd>:Octo actions<cr>", desc = "Open Octo" },
            { "<leader>Gs", "<cmd>:Octo pr list states=OPEN<cr>", desc = "Search Open PRs" },
            {
                "<leader>Gp",
                function()
                    vim.notify("Loading PR for current branch...", vim.log.levels.INFO)
                    vim.cmd("Octo pr")
                end,
                desc = "View PR for current branch",
            },
            {
                "<leader>Gc",
                function()
                    vim.notify("Loading checks for current pr...", vim.log.levels.INFO)
                    vim.cmd("Octo pr checks")
                end,
                desc = "View PR checks",
            },
            {
                "<leader>Go",
                function()
                    vim.notify("Opening PR in browser", vim.log.levels.INFO)
                    vim.cmd("silent !gh pr view --web")
                end,
                desc = "Open PR in browser",
            },
            {
                "<leader>Gy",
                function() vim.cmd("Octo pr url") end,
                desc = "Copy PR URL to clipboard",
            },
        },
    },
}
