local sclang = require("tidal.config").options.boot.sclang
sclang.enabled = true
sclang.file = vim.fn.getcwd() .. "/superdirt.scd"

vim.lsp.enable("hls", false)
