-- rust-analyzer server config: always analyze projects with all cargo features
-- enabled. AstroNvim v3 loads this file via `user_opts("lsp.config.rust_analyzer")`
-- and deep-merges it over the lspconfig defaults (see lua/astronvim/utils/lsp.lua).
return {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        -- `cargo.allFeatures` was removed upstream in favor of `features = "all"`
        -- (the old key is still accepted via a compatibility patch, but deprecated)
        features = "all",
      },
    },
  },
}
