local M = {}

local pickers = {}
local picker_functions = {}
local picker_index = 1

M.register_picker = function(picker_name, functions)
    for _, name in ipairs(pickers) do
        if name == picker_name then
            vim.notify("Picker " .. picker_name .. " already registered")
            return
        end
    end

    for fn_name, fn in pairs(functions) do
        if type(fn) ~= "function" or not M.maps[fn_name] then
            vim.notify("Picker " .. picker_name .. " contains invalid function: " .. fn_name)
        end
    end

    table.insert(pickers, picker_name)
    picker_functions[picker_name] = functions
end

M.change_picker = function(new_picker)
    for i, name in ipairs(pickers) do
        if name == new_picker then
            picker_index = i
            break
        end
        vim.notify("Picker " .. new_picker .. " not found")
    end
    vim.notify("Picker: " .. pickers[picker_index])
end

M.cycle_picker = function()
    picker_index = (picker_index + 1) > #pickers and 1 or picker_index + 1
    vim.notify("Picker: " .. pickers[picker_index])
end

M.maps = {
    find_files = { "<C-p>", "Find Files" },
    buffers = { "<C-b>", "Buffers" },
    live_grep = { "<C-f>", "Live Grep" },
    lsp_definitions = { "gd", "Go to Definition" },
    lsp_references = { "gr", "Go to References" },
    lsp_type_definitions = { "gt", "Go to Type Definition" },
    keymaps = { "<leader>km", "Keymaps" },
    help_tags = { "<leader>?", "Help Tags" },
    commands = { "<leader><leader>", "Commands" },
    buffer_fuzzy = { "<leader>/f", "Current Buffer Fuzzy Search" },
    pickers = { "<leader>pp", "Pickers" },
}

local call = function(fn_name, ...)
    local current_picker = pickers[picker_index]
    if picker_functions[current_picker] and picker_functions[current_picker][fn_name] then
        picker_functions[current_picker][fn_name](...)
    else
        for i = 1, #pickers do
            local fallback = pickers[i]
            if picker_functions[fallback] and picker_functions[fallback][fn_name] then
                picker_functions[fallback][fn_name](...)
                return
            end
        end
        logger("Not found: " .. current_picker .. " " .. fn_name)
    end
end

for name, opts in pairs(M.maps) do
    vim.keymap.set("n", opts[1], function() call(name) end, {
        desc = opts[2],
    })
end

vim.api.nvim_create_user_command("CyclePicker", function() M.cycle_picker() end, {})

return M
