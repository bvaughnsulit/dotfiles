return {
    {
        "neovim/nvim-lspconfig",
        keys = {
            {
                "K",
                function() return vim.lsp.buf.hover() end,
                desc = "Hover",
            },
            {
                "gK",
                function() return vim.lsp.buf.signature_help() end,
                desc = "Signature Help",
            },
            {
                "<c-k>",
                function() return vim.lsp.buf.signature_help() end,
                mode = "i",
                desc = "Signature Help",
                -- has = 'signatureHelp',
            },
            {
                "<leader>ca",
                vim.lsp.buf.code_action,
                desc = "Code Action",
                mode = { "n", "v" },
                -- has = 'codeAction',
            },
            {
                "<leader>cR",
                function() Snacks.rename.rename_file() end,
                desc = "Rename File",
                mode = { "n" },
                -- has = { 'workspace/didRenameFiles', 'workspace/willRenameFiles' },
            },
            {
                "<leader>cr",
                vim.lsp.buf.rename,
                desc = "Rename",
                -- has = 'rename',
            },
            {
                "<leader>cA",
                LazyVim.lsp.action.source,
                desc = "Source Action",
                -- has = 'codeAction',
            },
        },
        ---@diagnostic disable: missing-fields
        opts = function()
            local opts = {
                inlay_hints = { enabled = false },
                diagnostics = {
                    virtual_text = false,
                    signs = {
                        text = {
                            [vim.diagnostic.severity.ERROR] = "",
                            [vim.diagnostic.severity.WARN] = "",
                            [vim.diagnostic.severity.INFO] = "",
                            [vim.diagnostic.severity.HINT] = "",
                        },
                        numhl = {
                            [vim.diagnostic.severity.ERROR] = "DiagnosticError",
                            [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
                            [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
                            [vim.diagnostic.severity.HINT] = "DiagnosticHint",
                        },
                    },
                    float = {
                        wrap = true,
                        max_width = 120,
                        source = true,
                        border = "rounded",
                        style = "minimal",
                    },
                },
                ---@type table<string, lspconfig.Config>
                servers = {
                    pyright = {
                        enabled = false,
                        root_dir = function(fname)
                            local util = require("lspconfig.util")
                            ---@diagnostic disable-next-line: redundant-return-value
                            return util.root_pattern(".git")(fname)
                        end,
                        settings = {
                            python = {
                                analysis = {
                                    --- @type ("off" | "basic" | "standard" | "strict")
                                    typeCheckingMode = "standard",
                                    --- @type ("openFilesOnly" | "workspace")
                                    diagnosticMode = "openFilesOnly",
                                },
                            },
                        },
                    },
                    basedpyright = {
                        root_dir = function(fname)
                            local util = require("lspconfig.util")
                            ---@diagnostic disable-next-line: redundant-return-value
                            return util.root_pattern(".git")(fname)
                        end,
                        settings = {
                            basedpyright = {
                                analysis = {
                                    --- @type ("off" | "basic" | "standard" | "strict")
                                    typeCheckingMode = "standard",
                                    --- @type ("openFilesOnly" | "workspace")
                                    diagnosticMode = "openFilesOnly",
                                },
                            },
                        },
                    },
                    eslint = {
                        settings = {
                            workingDirectory = { mode = "location" },
                        },
                    },
                    vtsls = {
                        settings = {
                            typescript = {
                                format = {
                                    enable = false,
                                },
                            },
                        },
                    },
                    ts_ls = {
                        enabled = false,
                    },
                },
            }

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client.name == "eslint" then
                        client.server_capabilities.documentFormattingProvider = true
                    elseif client and client.name == "ts_ls" then
                        client.server_capabilities.documentFormattingProvider = false
                    end

                    vim.o.foldlevel = 99
                    vim.o.foldmethod = "expr"
                    vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    if client and client:supports_method("textDocument/foldingRange") then
                        local win = vim.api.nvim_get_current_win()
                        vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
                    end
                    vim.cmd([[hi! default link Folded LspInlayHint]])
                end,
            })
            return opts
        end,
        ---@diagnostic enable: missing-fields
    },
    {
        "folke/neoconf.nvim",
        lazy = false,
        init = function()
            require("neoconf").setup({
                local_settings = ".__bvs__neoconf.json",
                import = { vscode = false },
            })
        end,
    },
    {
        "mfussenegger/nvim-lint",
        opts = {
            linters_by_ft = {
                python = { "pylint" },
            },
        },
    },
}
