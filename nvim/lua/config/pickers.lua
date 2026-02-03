local M = {}

---@enum PickerNames
local pickers = {
    snacks = "snacks",
    telescope = "telescope",
    mini = "mini",
    ["fzf-lua"] = "fzf-lua",
}

---@type PickerNames
local default_picker = "fzf-lua"

---@type PickerNames[]
M.registered_pickers = {}

---@type table<string, {lhs: string, desc: string, mode?: table<string>, rhs: table<string, function>, selected_picker: string|nil}>
M.picker_functions = {
    find_files = { lhs = "<C-p>", desc = "Find Files", rhs = {}, selected_picker = nil },
    buffers = { lhs = "<C-b>", desc = "Buffers", mode = { "n", "v", "t" }, rhs = {}, selected_picker = nil },
    live_grep = { lhs = "<C-f>", desc = "Live Grep", rhs = {}, selected_picker = nil },
    lsp_definitions = { lhs = "gd", desc = "Go to Definition", rhs = {}, selected_picker = nil },
    lsp_references = { lhs = "gr", desc = "Go to References", rhs = {}, selected_picker = nil },
    lsp_type_definitions = { lhs = "gt", desc = "Go to Type Definition", rhs = {}, selected_picker = nil },
    keymaps = { lhs = "<leader>fm", desc = "[F]ind [M]appings", rhs = {}, selected_picker = nil },
    help_tags = { lhs = "<leader>?", desc = "Help Tags", rhs = {}, selected_picker = nil },
    commands = { lhs = "<leader><leader>", desc = "Commands", rhs = {}, selected_picker = nil },
    buffer_fuzzy = { lhs = "<leader>/f", desc = "Current Buffer Fuzzy Search", rhs = {}, selected_picker = nil },
    pickers = { lhs = "<leader>pp", desc = "Pickers", rhs = {}, selected_picker = default_picker },
    resume = { lhs = "<leader><up>", desc = "Resume Last Picker", rhs = {}, selected_picker = nil },
}

---@param picker_name PickerNames
---@param functions table<string, function>
M.register_picker = function(picker_name, functions)
    table.insert(M.registered_pickers, picker_name)
    for fn_name, fn in pairs(functions) do
        if type(fn) ~= "function" or not M.picker_functions[fn_name] then
            vim.notify("Picker " .. picker_name .. " contains invalid function: " .. fn_name)
        end
        M.picker_functions[fn_name].rhs[picker_name] = fn
    end
end

local call = function(fn_name, ...)
    local selected_picker = M.picker_functions[fn_name].selected_picker or default_picker

    if M.picker_functions[fn_name].rhs[selected_picker] then
        M.picker_functions[fn_name].rhs[selected_picker](...)
        return
    else
        for _, fn in pairs(M.picker_functions[fn_name].rhs) do
            fn(...)
            return
        end
        logger("No valid picker function found for " .. fn_name)
    end
end

for name, opts in pairs(M.picker_functions) do
    vim.keymap.set(opts.mode or { "n", "v" }, opts.lhs, function() call(name) end, {
        desc = opts.desc,
    })
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
        elseif M.picker_functions[selected_picker_fn] then
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
