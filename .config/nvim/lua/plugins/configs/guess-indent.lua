return function(_, opts)
  require("guess-indent").setup(opts)
  -- guess the indent of the buffer that triggered loading (signature is now `set_from_buffer(bufnr, context, silent)`)
  require("guess-indent").set_from_buffer(nil, "auto_cmd", true)
end
