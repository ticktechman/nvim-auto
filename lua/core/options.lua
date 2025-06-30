-------------------------------------------------------------------------------
--
--       filename: options.lua
--    description:
--        created: 2025/06/30
--         author: ticktechman
--
-------------------------------------------------------------------------------

local o = vim.opt

o.number = true
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.termguicolors = true
o.ignorecase = true
o.syntax = "enable"
o.clipboard = "unnamedplus"
vim.o.undofile = true
vim.g.mapleader = ","

vim.g.install_home_dir = vim.fn.stdpath("config") .. "/.packages"

-------------------------------------------------------------------------------
