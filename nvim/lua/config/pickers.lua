local M = {}

---@enum PickerNames
local pickers = {
    snacks = "snacks",
    telescope = "telescope",
    mini = "mini",
    ["fzf-lua"] = "fzf-lua",
}

---@type PickerNames
local default_picker = "snacks"

---@type PickerNames[]
M.registered_pickers = {}

---@type table<string, {lhs: string, desc: string, mode?: table<string>, rhs: table<string, function>|nil, selected_picker: string|nil}>
M.picker_functions = {
    find_files = {
        lhs = "<C-p>",
        desc = "Find Files",
    },
    buffers = {
        lhs = "<C-b>",
        desc = "Buffers",
        mode = { "n", "v", "t" },
    },
    live_grep = {
        lhs = "<C-f>",
        desc = "Live Grep",
    },
    live_grep_no_filters = {
        lhs = "<leader><C-f>",
        desc = "Live Grep (no filters)",
    },
    lsp_definitions = {
        lhs = "gd",
        desc = "Go to Definition",
    },
    lsp_references = {
        lhs = "gr",
        desc = "Go to References",
    },
    lsp_type_definitions = {
        lhs = "gt",
        desc = "Go to Type Definition",
    },
    keymaps = {
        lhs = "<leader>fm",
        desc = "[F]ind [M]appings",
    },
    help_tags = {
        lhs = "<leader>?",
        desc = "Help Tags",
    },
    commands = {
        lhs = "<leader><leader>",
        desc = "Commands",
    },
    buffer_fuzzy = {
        lhs = "<leader>/f",
        desc = "Current Buffer Fuzzy Search",
    },
    pickers = {
        lhs = "<leader>pp",
        desc = "Pickers",
    },
    resume = {
        lhs = "<leader><up>",
        desc = "Resume Last Picker",
    },
    autocmds = { lhs = "", desc = "" },
    cliphist = { lhs = "", desc = "" },
    colorschemes = { lhs = "", desc = "" },
    diagnostics = { lhs = "", desc = "" },
    diagnostics_buffer = { lhs = "", desc = "" },
    explorer = { lhs = "", desc = "" },
    files = { lhs = "", desc = "" },
    gh_actions = { lhs = "", desc = "" },
    gh_diff = { lhs = "", desc = "" },
    gh_issue = { lhs = "", desc = "" },
    gh_labels = { lhs = "", desc = "" },
    gh_pr = { lhs = "", desc = "" },
    gh_reactions = { lhs = "", desc = "" },
    git_branches = { lhs = "", desc = "" },
    git_diff = { lhs = "", desc = "" },
    git_files = { lhs = "", desc = "" },
    git_grep = { lhs = "", desc = "" },
    git_log = { lhs = "", desc = "" },
    git_log_file = { lhs = "", desc = "" },
    git_log_line = { lhs = "", desc = "" },
    git_stash = { lhs = "", desc = "" },
    git_status = { lhs = "", desc = "" },
    grep = { lhs = "", desc = "" },
    grep_buffers = { lhs = "", desc = "" },
    grep_word = { lhs = "", desc = "" },
    help = { lhs = "", desc = "" },
    highlights = { lhs = "", desc = "" },
    icons = { lhs = "", desc = "" },
    jumps = { lhs = "", desc = "" },
    lazy = { lhs = "", desc = "" },
    lines = { lhs = "", desc = "" },
    loclist = { lhs = "", desc = "" },
    lsp_config = { lhs = "", desc = "" },
    lsp_declarations = { lhs = "", desc = "" },
    lsp_implementations = { lhs = "", desc = "" },
    lsp_incoming_calls = { lhs = "", desc = "" },
    lsp_outgoing_calls = { lhs = "", desc = "" },
    lsp_symbols = { lhs = "", desc = "" },
    lsp_workspace_symbols = { lhs = "", desc = "" },
    man = { lhs = "", desc = "" },
    marks = { lhs = "", desc = "" },
    noice = { lhs = "", desc = "" },
    notifications = { lhs = "", desc = "" },
    projects = { lhs = "", desc = "" },
    qflist = { lhs = "", desc = "" },
    recent = { lhs = "", desc = "" },
    registers = { lhs = "", desc = "" },
    scratch = { lhs = "", desc = "" },
    select = { lhs = "", desc = "" },
    smart = { lhs = "", desc = "" },
    spelling = { lhs = "", desc = "" },
    tags = { lhs = "", desc = "" },
    todo_comments = { lhs = "", desc = "" },
    treesitter = { lhs = "", desc = "" },
    undo = { lhs = "", desc = "" },
    zoxide = { lhs = "", desc = "" },
}

---@param picker_name PickerNames
---@param functions table<string, function>
M.register_picker = function(picker_name, functions)
    if not vim.tbl_contains(M.registered_pickers, picker_name) then table.insert(M.registered_pickers, picker_name) end
    for fn_name, fn in pairs(functions) do
        if type(fn) ~= "function" or not M.picker_functions[fn_name] then
            vim.notify("Picker " .. picker_name .. " contains invalid function: " .. fn_name)
        end
        if not M.picker_functions[fn_name].rhs then M.picker_functions[fn_name].rhs = {} end
        M.picker_functions[fn_name].rhs[picker_name] = fn
    end
end

local call = function(fn_name, ...)
    local selected_picker = M.picker_functions[fn_name].selected_picker or default_picker

    if M.picker_functions[fn_name].rhs and M.picker_functions[fn_name].rhs[selected_picker] then
        M.picker_functions[fn_name].rhs[selected_picker](...)
        return
    elseif M.picker_functions[fn_name].rhs then
        for _, fn in pairs(M.picker_functions[fn_name].rhs) do
            fn(...)
            return
        end
    end
    vim.notify("No valid picker function found for " .. fn_name)
end

for name, opts in pairs(M.picker_functions) do
    if #opts.lhs > 0 then
        vim.keymap.set(opts.mode or { "n", "v" }, opts.lhs, function() call(name) end, {
            desc = opts.desc,
        })
    end
end

local update_selected_picker = function()
    local opts = vim.tbl_keys(M.picker_functions)
    table.insert(opts, 1, "all")

    vim.ui.select(opts, {
        prompt = "Select a function to configure:",
    }, function(selected_picker_fn)
        if selected_picker_fn == "all" then
            vim.ui.select(M.registered_pickers, {
                prompt = "Select default picker for all functions:",
            }, function(selected_picker)
                if not selected_picker then return end
                for fn_name, _ in pairs(M.picker_functions) do
                    M.picker_functions[fn_name].selected_picker = nil
                    default_picker = selected_picker
                end
                vim.notify("Default picker for all functions set to " .. selected_picker)
            end)
        elseif M.picker_functions[selected_picker_fn] and M.picker_functions[selected_picker_fn].rhs then
            vim.ui.select(vim.tbl_keys(M.picker_functions[selected_picker_fn].rhs), {
                prompt = "Select picker for " .. selected_picker_fn .. ":",
            }, function(selected_picker)
                if M.picker_functions[selected_picker_fn].rhs[selected_picker] then
                    M.picker_functions[selected_picker_fn].selected_picker = selected_picker
                    vim.notify("Default picker for " .. selected_picker_fn .. " set to " .. selected_picker)
                end
            end)
        end
    end)
end

vim.keymap.set("n", "<leader>pP", update_selected_picker, {
    desc = "Update Picker Selections",
})

return M
