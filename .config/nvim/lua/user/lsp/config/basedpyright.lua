-- Custom server definition for basedpyright.
--
-- The pinned nvim-lspconfig (commit e49b1e9, 2023-10-16) predates upstream
-- basedpyright support (added Feb 2024), so lspconfig has no built-in config for
-- it. AstroNvim v3 registers a custom server from this file when it returns a
-- `cmd` (see lua/astronvim/utils/lsp.lua:81-84). Fields below mirror upstream
-- lspconfig's basedpyright default_config.
local util = require "lspconfig.util"

return {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_dir = function(fname)
    -- markers upstream uses to locate the project root
    local root_files = {
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      "pyrightconfig.json",
      ".git",
    }
    return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
  end,
  single_file_support = true,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
        -- suppress missing type annotation warnings
        diagnosticSeverityOverrides = {
          reportMissingParameterType = "none",
          reportUnknownParameterType = "none",
          reportUnknownArgumentType = "none",
          reportUnknownVariableType = "none",
          reportUnknownMemberType = "none",
          reportUnknownLambdaType = "none",
          reportMissingTypeArgument = "none",
          reportUntypedFunctionDecorator = "none",
          reportUntypedClassDecorator = "none",
          reportUntypedBaseClass = "none",
          reportUntypedNamedTuple = "none",
        },
      },
    },
  },
}
