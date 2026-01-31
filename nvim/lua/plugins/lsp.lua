---@type table<string, vim.lsp.Config>
local servers = {
    lua_ls = {
        settings = {
            Lua = {
                workspace = {
                    checkThirdParty = false,
                },
                codeLens = {
                    enable = true,
                },
                completion = {
                    callSnippet = "Replace",
                },
                doc = {
                    privateName = { "^_" },
                },
                hint = {
                    enable = true,
                    setType = false,
                    paramType = true,
                    paramName = "Disable",
                    semicolon = "Disable",
                    arrayIndex = "Disable",
                },
            },
        },
    },
    pyright = {
        -- root_dir = function(fname)
        --     local util = require("lspconfig.util")
        --     ---@diagnostic disable-next-line: redundant-return-value
        --     return util.root_pattern(".git")(fname)
        -- end,
        root_markers = { ".git" },
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
        -- root_dir = function(fname)
        --     local util = require("lspconfig.util")
        --     ---@diagnostic disable-next-line: redundant-return-value
        --     return util.root_pattern(".git")(fname)
        -- end,
        root_markers = { ".git" },
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
            javascript = {
                format = {
                    enable = false,
                },
            },
        },
    },
}

---@module 'lazy'
---@type LazySpec
return {
    {
        "https://github.com/neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile", "BufWritePre" },
        dependencies = { "https://github.com/mason-org/mason.nvim" },
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
            },
            {
                "<leader>ca",
                vim.lsp.buf.code_action,
                desc = "Code Action",
                mode = { "n", "v" },
            },
            {
                "<leader>cR",
                function() Snacks.rename.rename_file() end,
                desc = "Rename File",
                mode = { "n" },
            },
            {
                "<leader>cr",
                vim.lsp.buf.rename,
                desc = "Rename",
            },
        },
        config = function()
            vim.diagnostic.config({
                underline = true,
                update_in_insert = false,
                severity_sort = true,
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
            })

            ---@param client vim.lsp.Client
            local on_attach = function(client, _buffer)
                if client and client.name == "eslint" then
                    client.server_capabilities.documentFormattingProvider = true
                elseif client and client.name == "vtsls" then
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
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client then return on_attach(client, args.buf) end
                end,
            })

            -- i dunno if this is necessary
            local register_capability = vim.lsp.handlers["client/registerCapability"]
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
                local client = vim.lsp.get_client_by_id(ctx.client_id)
                if client then
                    for buffer in pairs(client.attached_buffers) do
                        on_attach(client, buffer)
                    end
                end
                return register_capability(err, res, ctx)
            end

            for name, config in pairs(servers) do
                local disabled = { "basedpyright" }
                if not vim.tbl_contains(disabled, name) then
                    vim.lsp.config(name, config)
                    vim.lsp.enable(name)
                end
            end

            vim.lsp.set_log_level(vim.lsp.log_levels.WARN)
            vim.lsp.log.set_format_func(vim.inspect)

            local set_lsp_log_level = function()
                vim.ui.select(vim.tbl_keys(vim.log.levels), {
                    prompt = "Select a level",
                }, function(selection)
                    if selection then
                        vim.lsp.set_log_level(vim.log.levels[selection])
                        vim.notify(
                            "LSP log level set to: " .. vim.lsp.log_levels[vim.lsp.log.get_level()],
                            vim.log.levels.INFO
                        )
                    else
                        vim.notify("Invalid selection", vim.log.levels.WARN)
                    end
                end)
            end
            vim.keymap.set("n", "<leader>lsl", set_lsp_log_level, { desc = "Set LSP log level" })
        end,
    },
    {
        "https://github.com/folke/neoconf.nvim",
        lazy = false,
        init = function()
            require("neoconf").setup({
                local_settings = ".__bvs__neoconf.json",
                import = { vscode = false },
            })
        end,
    },
    {
        "https://github.com/mfussenegger/nvim-lint",
        event = "VeryLazy",
        opts = {
            linters_by_ft = {
                python = { "pylint" },
            },
        },
        config = function(_, opts)
            local lint = require("lint")
            lint.linters_by_ft = opts.linters_by_ft

            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = function() require("lint").try_lint() end,
            })
        end,
    },
    {
        "https://github.com/stevearc/conform.nvim",
        dependencies = { "https://github.com/mason-org/mason.nvim" },
        event = "VeryLazy",
        cmd = "ConformInfo",
        ---@module 'conform'
        ---@type conform.setupOpts
        opts = {
            format_on_save = function(bufnr)
                if vim.g.autoformat == false then return nil end
                return {
                    lsp_format = "fallback",
                    timeout_ms = 500,
                }
            end,
            default_format_opts = {
                timeout_ms = 3000,
                async = false,
                quiet = false,
                lsp_format = "fallback",
            },
            formatters_by_ft = {
                lua = { "stylua" },
                sh = { "shfmt" },
            },
            formatters = {
                injected = { options = { ignore_errors = true } },
            },
        },
    },
    {
        "https://github.com/mason-org/mason.nvim",
        cmd = "Mason",
        event = "VeryLazy",
        build = ":MasonUpdate",
        opts = {},
    },
    {
        "https://github.com/mason-org/mason-lspconfig.nvim",
        dependencies = {
            "https://github.com/mason-org/mason.nvim",
            "https://github.com/neovim/nvim-lspconfig",
        },
        opts = {
            ensure_installed = vim.tbl_keys(servers),
            automatic_enable = false,
        },
    },
}
