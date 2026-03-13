---@class PythonTestRunnerOpts
---@field module 'unittest' | 'pytest' The test runner module to use for Python tests.
---@field args? string[] Additional command-line arguments to pass to the test runner.
---@field env? table<string, string> Environment variables to set when running Python tests.

---@class ConfigDefaults
---@field grep_exclude string[] List of file patterns to exclude from grep operations.
---@field python_test_runner_opts PythonTestRunnerOpts Configuration options for the Python test runner.
local defaults = {
    grep_exclude = {},
    python_test_runner_opts = {
        module = "unittest",
        args = nil,
        env = nil,
    },
    claude_dirs = {},
}

return require("neoconf").get("config", defaults)
