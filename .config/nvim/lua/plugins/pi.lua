return {
  "carderne/pi-nvim",
  cmd = {
    "Pi",
    "PiSend",
    "PiSendFile",
    "PiSendSelection",
    "PiSendBuffer",
    "PiPing",
    "PiSessions",
  },
  opts = {},
  config = function(_, opts) require("pi-nvim").setup(opts) end,
}
