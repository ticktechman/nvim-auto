-------------------------------------------------------------------------------
--
--       filename: editor.lua
--    description:
--        created: 2025/06/30
--         author: ticktechman
--
-------------------------------------------------------------------------------

return {
  ----------------------------
  -- highlight whitespace
  ----------------------------
  { "ntpeters/vim-better-whitespace", lazy = false },

  ----------------------------
  -- blankline identicator
  ----------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    lazy = false,
    main = "ibl",
    event = "User FilePost",
    config = function()
      require("ibl").setup({
        indent = { char = "┆" },
        scope = {
          enabled = false,
          show_start = true,
          show_end = false,
        },
      })
    end,
  },
}

-------------------------------------------------------------------------------
