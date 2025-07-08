---@class ConfigDefaults
---@field agent string The default AI agent
---@field grep_exclude string[] List of file patterns to exclude from grep operations.
local defaults = {
    agent = "gemini",
    grep_exclude = {},
}

return require("neoconf").get("config", defaults)
