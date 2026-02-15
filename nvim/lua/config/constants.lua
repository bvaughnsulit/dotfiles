local M = {}

---@enum (key) Kind
M.kind_map = {
    Array = { abbrev = "Arr", icon = " " },
    Boolean = { abbrev = "Bool", icon = "󰨙 " },
    Class = { abbrev = "Class", icon = " " },
    Collapsed = { abbrev = "Collapsed", icon = " " },
    Color = { abbrev = "Color", icon = " " },
    Constant = { abbrev = "Const", icon = "󰏿 " },
    Constructor = { abbrev = "Constr", icon = " " },
    Control = { abbrev = "Ctrl", icon = " " },
    Enum = { abbrev = "Enum", icon = " " },
    EnumMember = { abbrev = "Mem", icon = " " },
    Event = { abbrev = "Evt", icon = " " },
    Field = { abbrev = "Field", icon = " " },
    File = { abbrev = "File", icon = " " },
    Folder = { abbrev = "Folder", icon = " " },
    Function = { abbrev = "Func", icon = "󰊕 " },
    Interface = { abbrev = "Inter", icon = " " },
    Key = { abbrev = "Key", icon = " " },
    Keyword = { abbrev = "Kwd", icon = " " },
    Method = { abbrev = "Meth", icon = "󰊕 " },
    Module = { abbrev = "Module", icon = " " },
    Namespace = { abbrev = "Namespc", icon = "󰦮 " },
    Null = { abbrev = "Null", icon = "󰟢 " },
    Number = { abbrev = "Num", icon = "󰎠 " },
    Object = { abbrev = "Obj", icon = " " },
    Operator = { abbrev = "Op", icon = " " },
    Package = { abbrev = "Pkg", icon = " " },
    Property = { abbrev = "Prop", icon = " " },
    Reference = { abbrev = "Ref", icon = " " },
    Snippet = { abbrev = "Snip", icon = "󰩫 " },
    String = { abbrev = "Str", icon = "󱀍 " },
    Struct = { abbrev = "Struct", icon = " " },
    Text = { abbrev = "Text", icon = " " },
    TypeParameter = { abbrev = "TypeParam", icon = " " },
    Unit = { abbrev = "Unit", icon = " " },
    Unknown = { abbrev = "Unknown", icon = " " },
    Value = { abbrev = "Val", icon = "󱄽 " },
    Variable = { abbrev = "Var", icon = " " },
}
M.kind = {}

for key, value in pairs(M.kind_map) do
    M.kind[key] = "[" .. value.icon .. value.abbrev .. "]"
end

---@type table<string, Kind[]>
M.ft_kind_filter = {
    ["_"] = {
        "File",
        "Module",
        "Namespace",
        "Class",
        "Method",
        "Field",
        "Constructor",
        "Enum",
        "Function",
        "Object",
        "Key",
        "EnumMember",
        "Struct",
        "Event",
        "TypeParameter",
        "Interface",
        "Unknown",
    },
    python = {
        "File",
        "Module",
        "Namespace",
        "Class",
        "Method",
        "Field",
        "Constructor",
        "Enum",
        "Function",
        "Object",
        "Key",
        "EnumMember",
        "Struct",
        "Event",
        "TypeParameter",
    },
    typescript = {
        "Variable",
        "File",
        "Module",
        "Namespace",
        "Class",
        "Method",
        "Field",
        "Constructor",
        "Enum",
        "Function",
        "Object",
        "Key",
        "EnumMember",
        "Struct",
        "Event",
        "TypeParameter",
    },
}

M.ft_kind_filter["javascript"] = M.ft_kind_filter["typescript"]
M.ft_kind_filter["javascriptreact"] = M.ft_kind_filter["typescript"]
M.ft_kind_filter["typescriptreact"] = M.ft_kind_filter["typescript"]

return M
