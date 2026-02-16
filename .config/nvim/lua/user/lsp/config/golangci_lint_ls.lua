-- Configuration for golangci-lint-langserver with golangci-lint v2
-- The --out-format flag was removed in v2, replaced with --output.json.path
return {
  init_options = {
    command = {
      "golangci-lint",
      "run",
      "--output.json.path", "stdout",
      "--show-stats=false",
      "--issues-exit-code=1",
    },
  },
}
