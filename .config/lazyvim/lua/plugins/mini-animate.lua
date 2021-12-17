return {
  {
    "echasnovski/mini.animate",
    opts = function(_, opts)
      local animate = require("mini.animate")
      opts.cursor = {
        timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
      }
    end,
  },
}
