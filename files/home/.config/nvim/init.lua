-- NeoVIM main configuration file (requires >= v0.10.0)

-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end

vim.g.mapleader = " "
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({ { "sainnhe/gruvbox-material", config = function() vim.cmd [[colorscheme gruvbox-material]] end } })

local options = {
  backup = false, writebackup = false, undofile = true, swapfile = false,
  mouse = "a", clipboard = "unnamedplus,unnamed",
  cmdheight = 1, showmode = true,
  number = true, cursorline = true,
  hlsearch = true, ignorecase = true, smartcase = true,
  smartindent = true, shiftwidth = 2, tabstop = 2, expandtab = true,
  wrap = false, scrolloff = 8, sidescrolloff = 8,
}
for k, v in pairs(options) do vim.opt[k] = v end
