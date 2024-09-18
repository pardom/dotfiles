return {
  "nvim-neotest/neotest",
  dependencies = {
    "antoinemadec/FixCursorHold.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-neotest/nvim-nio",
    "nvim-treesitter/nvim-treesitter",
    "orjangj/neotest-ctest",
  },
  config = function()
    -- Optional, but recommended, if you have enabled neotest's diagnostic option
    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          -- Convert newlines, tabs and whitespaces into a single whitespace
          -- for improved virtual text readability
          local message = diagnostic.message:gsub("[\r\n\t%s]+", " ")
          return message
        end,
      },
    }, neotest_ns)

    require("neotest").setup({
      adapters = {
        -- Load with default config
        require("neotest-ctest").setup({
          frameworks = { "catch2" },
        }),
      },
    })
  end,
}
