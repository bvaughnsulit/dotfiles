local utils = require("config.utils")

local Format = require("noice.text.format")
local Message = require("noice.message")
local Manager = require("noice.message.manager")
local Router = require("noice.message.router")

local ThrottleTime = 200
local M = {}

M.handles = {}
function M.init()
    local group = vim.api.nvim_create_augroup("NoiceCompanionRequests", {})

    vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "CodeCompanionRequestStarted",
        group = group,
        callback = function(request)
            local handle = M.create_progress_message(request)
            M.store_progress_handle(request.data.id, handle)
            M.update(handle)
        end,
    })

    vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "CodeCompanionRequestFinished",
        group = group,
        callback = function(request)
            local message = M.pop_progress_message(request.data.id)
            if message then
                message.opts.progress.message = M.report_exit_status(request)
                M.finish_progress_message(message)
            end
        end,
    })
end

function M.store_progress_handle(id, handle) M.handles[id] = handle end

function M.pop_progress_message(id)
    local handle = M.handles[id]
    M.handles[id] = nil
    return handle
end

function M.create_progress_message(request)
    local msg = Message("lsp", "progress")
    local id = request.data.id
    msg.opts.progress = {
        client_id = "client " .. id,
        client = M.llm_role_title(request.data.adapter),
        id = id,
        message = "Awaiting Response: ",
    }
    return msg
end

function M.update(message)
    if M.handles[message.opts.progress.id] then
        Manager.add(Format.format(message, "lsp_progress"))
        vim.defer_fn(function() M.update(message) end, ThrottleTime)
    end
end

function M.finish_progress_message(message)
    Manager.add(Format.format(message, "lsp_progress"))
    Router.update()
    Manager.remove(message)
end

function M.llm_role_title(adapter)
    local parts = {}
    table.insert(parts, adapter.formatted_name)
    if adapter.model and adapter.model ~= "" then table.insert(parts, "(" .. adapter.model .. ")") end
    return table.concat(parts, " ")
end

function M.report_exit_status(request)
    if request.data.status == "success" then
        return "Completed"
    elseif request.data.status == "error" then
        return " Error"
    else
        return "󰜺 Cancelled"
    end
end

local system_prompt = [[
You are an AI programming assistant. You are currently plugged into the Neovim text editor on a user's machine.

Your core tasks include:
- Answering general programming questions.
- Explaining how the code in a Neovim buffer works.
- Reviewing the selected code in a Neovim buffer.
- Generating unit tests for the selected code.
- Proposing fixes for problems in the selected code.
- Scaffolding code for a new workspace.
- Finding relevant code to the user's query.
- Proposing fixes for test failures.
- Answering questions about Neovim.
- Running tools.

You must:
- Follow the user's requirements carefully and to the letter.
- Keep your answers short and impersonal.
- Minimize additional prose unless clarification is needed.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of each Markdown code block.
- Avoid including line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Only return code that's directly relevant to the task at hand. You may omit code that isn’t necessary for the solution.
- Avoid using H1 and H2 headers in your responses.
- Use actual line breaks in your responses; only use "\n" when you want a literal backslash followed by 'n'.
- All non-code text responses must be written in English.

When given a task:
1. Think step-by-step and, unless the user requests otherwise or the task is very simple, describe your plan in detailed pseudocode.
2. Output the final code in a single code block, ensuring that only relevant code is included.
3. Do not ask follow up questions unless you require additional context to effectively complete the task.
4. Provide exactly one complete reply per conversation turn.
]]

vim.keymap.set(
    "n",
    "<leader>aa",
    function()
        utils.toggle_persistent_terminal("claude", "claude", {
            q_to_go_back = { "n" },
            start_insert = true,
            auto_insert = false,
            win_config = {
                height = 10,
                split = "below",
            },
        })
    end,
    { desc = "Open AI Agent" }
)

return {
    {
        "olimorris/codecompanion.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            opts = {
                -- log_level = "INFO",
                system_prompt = system_prompt,
            },
            strategies = {
                chat = {
                    keymaps = {
                        close = {
                            modes = {
                                n = "q",
                                i = "<C-c>",
                            },
                            callback = "keymaps.close",
                            description = "Close Chat",
                        },
                        stop = {
                            modes = {
                                n = { "<C-c>", "<Esc>" },
                            },
                            callback = "keymaps.stop",
                            description = "Stop Request",
                        },
                        send = {
                            modes = {
                                n = { "<CR>", "<C-s>", "<leader>w" },
                                i = "<CR>",
                            },
                            callback = "keymaps.send",
                            description = "Send",
                        },
                    },
                    roles = {
                        ---@type string|fun(adapter: CodeCompanion.Adapter): string
                        llm = function(adapter) return "🤖 " .. adapter.formatted_name end,
                        user = "👤 Me",
                    },
                },
            },
            adapters = {
                copilot = function()
                    return require("codecompanion.adapters").extend("copilot", {
                        schema = {
                            model = {
                                -- default = "claude-3.5-sonnet",
                                default = "gemini-2.0-flash-001",
                            },
                        },
                    })
                end,
            },
            display = {
                chat = {
                    show_header_separator = true,
                    show_settings = true,
                    show_token_count = false,
                    start_in_insert_mode = true,
                },
            },
        },
        config = function(_, opts)
            M.init()
            require("codecompanion").setup(opts)

            utils.create_cmd_and_map(
                "",
                { mode = "v", lhs = "<leader>ac", opts = {} },
                ":'<,'>CodeCompanionChat<CR>",
                "Send visual selection to AI chat"
            )

            utils.create_cmd_and_map("", "<leader>ac", ":CodeCompanionChat<CR>", "Open AI chat window")
        end,
    },
}
