return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
      formatters = {
        clangd = {
          prepend_args = { "--style=file", "--fallback-style=LLVM" },
        },
      },
    },
  },
}
