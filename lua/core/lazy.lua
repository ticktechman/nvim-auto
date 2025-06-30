-------------------------------------------------------------------------------
--
--       filename: lazy.lua
--    description:
--        created: 2025/06/30
--         author: ticktechman
--
-------------------------------------------------------------------------------

-- use lazy.nvim for plugin management
local lazypath = vim.g.install_home_dir .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
}, {
  root = vim.g.install_home_dir .. "/lazy",
  install = { colorscheme = { "tokyonight" } },
  ui = { border = "rounded" },
})

-------------------------------------------------------------------------------
