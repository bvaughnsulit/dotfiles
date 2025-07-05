return {
    "luukvbaal/statuscol.nvim",
    event = "VeryLazy",
    enabled = true,
    opts = function()
        local builtin = require("statuscol.builtin")
        local opts = {
            segments = {
                {
                    text = { builtin.foldfunc },
                    condition = { false },
                    click = "v:lua.ScFa",
                },
                {
                    text = { "%s" },
                    click = "v:lua.ScSa",
                },
                {
                    text = { builtin.lnumfunc, " " },
                    condition = { true, builtin.not_empty },
                    click = "v:lua.ScLa",
                },
            },
            clickmod = "a",
            clickhandlers = {
                Lnum = function(args)
                    if args.button == "l" then
                        if args.mods:find("a") then
                            vim.ui.input({
                                prompt = "Log message: ",
                            }, function(input)
                                if input then
                                    require("dap").toggle_breakpoint(nil, nil, input ~= "" and input or "Logpoint")
                                end
                            end)
                        else
                            require("dap").toggle_breakpoint()
                        end
                    elseif args.button == "r" then
                        require("gitsigns").blame_line({ full = true })
                    end
                end,

                ["diagnostic/signs"] = function(args)
                    if args.button == "l" then
                        vim.diagnostic.open_float()
                    elseif args.button == "r" then
                        vim.lsp.buf.code_action()
                    end
                end,

                gitsigns = function(args)
                    if args.button == "l" then
                        require("gitsigns").preview_hunk()
                    else
                        require("gitsigns").preview_hunk()
                    end
                end,
            },
        }
        return opts
    end,
}
