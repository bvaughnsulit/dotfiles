local utils = require("config.utils")

local fn = function()
    local http_file = nil
    for _, win in ipairs(vim.fn.getwininfo()) do
        if vim.fn.getbufinfo(win.bufnr)[1].name:find("dap-eval://lua", 1, true) then
            http_file = win.bufnr
            break
        end
    end

    if http_file == nil then
        -- Create a new eval buffer if it doesn't exist
        local width = math.floor(vim.o.columns * 0.3)

        vim.cmd(width .. " vsplit dap-eval://lua")
        vim.api.nvim_buf_set_lines(0, 0, 1, false, { "debug_info()" })
        vim.cmd("w")

        vim.keymap.set("n", "q", function()
            require("dap").repl.close()
            vim.cmd("hide")
        end, { buffer = 0, silent = true })
    else
        -- if it already exists, execute the lines in the eval buffer
        vim.bo[http_file].modified = false
        local repl = require("dap.repl")
        local lines = vim.api.nvim_buf_get_lines(http_file, 0, -1, true)
        local lines_str = table.concat(lines, "\n")
        if lines_str ~= "" then
            repl.execute(lines_str)
            repl.open()
        end
    end
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "rest_nvim_result" },
    group = utils.augroup("rest_nvim_result_buf"),
    callback = function(event)
        logger("hello")

        vim.bo[event.buf].modifiable = false
    end,
})

---@module 'lazy'
---@type LazySpec
return {
    "https://github.com/rest-nvim/rest.nvim",
    cond = true,
    cmd = "Rest",
    config = function()
        vim.g.rest_nvim = {
            ui = {
                keybinds = {
                    prev = "H",
                    next = "L",
                },
            },
        }
    end,
    keys = {
        {
            "<leader>rr",
            fn,
            desc = "Rest Nvim: Send request under cursor",
        },
    },
}
