local LazyVim = {}

---@alias lsp.Client.filter {id?: number, bufnr?: number, name?: string, method?: string, filter?:fun(client: lsp.Client):boolean}

---@param opts? lsp.Client.filter
function LazyVim.get_clients(opts)
    local ret = {} ---@type vim.lsp.Client[]
    if vim.lsp.get_clients then
        ret = vim.lsp.get_clients(opts)
    else
        ---@diagnostic disable-next-line: deprecated
        ret = vim.lsp.get_active_clients(opts)
        if opts and opts.method then
            ---@param client vim.lsp.Client
            ret = vim.tbl_filter(
                function(client) return client.supports_method(opts.method, { bufnr = opts.bufnr }) end,
                ret
            )
        end
    end
    return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

---@param on_attach fun(client:vim.lsp.Client, buffer)
---@param name? string
function LazyVim.on_attach(on_attach, name)
    return vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local buffer = args.buf ---@type number
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and (not name or client.name == name) then return on_attach(client, buffer) end
        end,
    })
end

---@type table<string, table<vim.lsp.Client, table<number, boolean>>>
LazyVim._supports_method = {}

function LazyVim.setup()
    local register_capability = vim.lsp.handlers["client/registerCapability"]
    vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
        ---@diagnostic disable-next-line: no-unknown
        local ret = register_capability(err, res, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
            for buffer in pairs(client.attached_buffers) do
                vim.api.nvim_exec_autocmds("User", {
                    pattern = "LspDynamicCapability",
                    data = { client_id = client.id, buffer = buffer },
                })
            end
        end
        return ret
    end
    LazyVim.on_attach(LazyVim._check_methods)
    LazyVim.on_dynamic_capability(LazyVim._check_methods)
end

---@param client vim.lsp.Client
function LazyVim._check_methods(client, buffer)
    -- don't trigger on invalid buffers
    if not vim.api.nvim_buf_is_valid(buffer) then return end
    -- don't trigger on non-listed buffers
    if not vim.bo[buffer].buflisted then return end
    -- don't trigger on nofile buffers
    if vim.bo[buffer].buftype == "nofile" then return end
    for method, clients in pairs(LazyVim._supports_method) do
        clients[client] = clients[client] or {}
        if not clients[client][buffer] then
            if client.supports_method and client.supports_method(method, { bufnr = buffer }) then
                clients[client][buffer] = true
                vim.api.nvim_exec_autocmds("User", {
                    pattern = "LspSupportsMethod",
                    data = { client_id = client.id, buffer = buffer, method = method },
                })
            end
        end
    end
end

---@param fn fun(client:vim.lsp.Client, buffer):boolean?
---@param opts? {group?: integer}
function LazyVim.on_dynamic_capability(fn, opts)
    return vim.api.nvim_create_autocmd("User", {
        pattern = "LspDynamicCapability",
        group = opts and opts.group or nil,
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            local buffer = args.data.buffer ---@type number
            if client then return fn(client, buffer) end
        end,
    })
end

---@param method string
---@param fn fun(client:vim.lsp.Client, buffer)
function LazyVim.on_supports_method(method, fn)
    LazyVim._supports_method[method] = LazyVim._supports_method[method] or setmetatable({}, { __mode = "k" })
    return vim.api.nvim_create_autocmd("User", {
        pattern = "LspSupportsMethod",
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            local buffer = args.data.buffer ---@type number
            if client and method == args.data.method then return fn(client, buffer) end
        end,
    })
end

---@return _.lspconfig.options
function LazyVim.get_config(server)
    local configs = require("lspconfig.configs")
    return rawget(configs, server)
end

---@return {default_config:lspconfig.Config}
function LazyVim.get_raw_config(server)
    local ok, ret = pcall(require, "lspconfig.configs." .. server)
    if ok then return ret end
    return require("lspconfig.server_configurations." .. server)
end

function LazyVim.is_enabled(server)
    local c = LazyVim.get_config(server)
    return c and c.enabled ~= false
end

---@param server string
---@param cond fun( root_dir, config): boolean
function LazyVim.disable(server, cond)
    local util = require("lspconfig.util")
    local def = LazyVim.get_config(server)
    ---@diagnostic disable-next-line: undefined-field
    def.document_config.on_new_config = util.add_hook_before(
        def.document_config.on_new_config,
        function(config, root_dir)
            if cond(root_dir, config) then config.enabled = false end
        end
    )
end

LazyVim.action = setmetatable({}, {
    __index = function(_, action)
        return function()
            vim.lsp.buf.code_action({
                apply = true,
                context = {
                    only = { action },
                    diagnostics = {},
                },
            })
        end
    end,
})

---@class LspCommand: lsp.ExecuteCommandParams
---@field open? boolean
---@field handler? lsp.Handler

---@param opts LspCommand
function LazyVim.execute(opts)
    local params = {
        command = opts.command,
        arguments = opts.arguments,
    }
    if opts.open then
        require("trouble").open({
            mode = "lsp_command",
            params = params,
        })
    else
        return vim.lsp.buf_request(0, "workspace/executeCommand", params, opts.handler)
    end
end

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
            {
                "<leader>cA",
                LazyVim.action.source,
                desc = "Source Action",
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
            local on_attach = function(client, buffer)
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

            LazyVim.on_attach(on_attach)
            LazyVim.on_dynamic_capability(on_attach)
            LazyVim.setup()

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
        opts = {
            linters_by_ft = {
                python = { "pylint" },
            },
        },
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
