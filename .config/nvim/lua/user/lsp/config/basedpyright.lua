-- basedpyright settings. nvim-lspconfig now ships the server definition (cmd, filetypes, root markers) in
-- lsp/basedpyright.lua; AstroNvim merges this file over it with `vim.lsp.config` (see lua/astronvim/utils/lsp.lua).
return {
  settings = {
    basedpyright = {
      -- nvim-lspconfig's default turns tagged (unused/deprecated) hints off; the old custom definition kept them
      disableTaggedHints = false,
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
