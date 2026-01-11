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

return {
    {
        "https://github.com/neovim/nvim-lspconfig.git",
        event = { "BufReadPre", "BufNewFile", "BufWritePre" },
        dependencies = { "mason.nvim" },
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
        end,
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
        event = "VeryLazy",
        opts = {
            linters_by_ft = {
                python = { "pylint" },
            },
        },
        config = function(_, opts)
            local M = {}

            local lint = require("lint")
            for name, linter in pairs(opts.linters) do
                if type(linter) == "table" and type(lint.linters[name]) == "table" then
                    lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
                    if type(linter.prepend_args) == "table" then
                        lint.linters[name].args = lint.linters[name].args or {}
                        vim.list_extend(lint.linters[name].args, linter.prepend_args)
                    end
                else
                    lint.linters[name] = linter
                end
            end
            lint.linters_by_ft = opts.linters_by_ft

            function M.debounce(ms, fn)
                local timer = vim.uv.new_timer()
                return function(...)
                    local argv = { ... }
                    timer:start(ms, 0, function()
                        timer:stop()
                        vim.schedule_wrap(fn)(unpack(argv))
                    end)
                end
            end

            function M.lint()
                -- Use nvim-lint's logic first:
                -- * checks if linters exist for the full filetype first
                -- * otherwise will split filetype by "." and add all those linters
                -- * this differs from conform.nvim which only uses the first filetype that has a formatter
                local names = lint._resolve_linter_by_ft(vim.bo.filetype)

                -- Create a copy of the names table to avoid modifying the original.
                names = vim.list_extend({}, names)

                -- Add fallback linters.
                if #names == 0 then vim.list_extend(names, lint.linters_by_ft["_"] or {}) end

                -- Add global linters.
                vim.list_extend(names, lint.linters_by_ft["*"] or {})

                -- Filter out linters that don't exist or don't match the condition.
                local ctx = { filename = vim.api.nvim_buf_get_name(0) }
                ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
                names = vim.tbl_filter(function(name)
                    local linter = lint.linters[name]
                    return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
                end, names)

                -- Run linters.
                if #names > 0 then lint.try_lint(names) end
            end

            events =
                { "BufWritePost", "BufReadPost", "InsertLeave" }, vim.api.nvim_create_autocmd(opts.events, {
                    group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                    callback = M.debounce(100, M.lint),
                })
        end,
    },
    {
        "stevearc/conform.nvim",
        dependencies = { "mason.nvim" },
        event = "VeryLazy",
        cmd = "ConformInfo",
        ---@module 'conform'
        ---@type conform.setupOpts
        opts = {
            format_on_save = {
                lsp_format = "fallback",
                timeout_ms = 500,
            },
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
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        opts = {
            ensure_installed = vim.tbl_keys(servers),
            automatic_enable = false,
        },
    },
}
