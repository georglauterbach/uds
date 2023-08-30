-- NeoVIM main configuration file (requires >= v0.10.0)

local ensure_packer = function()
  local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- custom plugins go here
  use { 'morhetz/gruvbox', config = function() vim.cmd [[colorscheme gruvbox]] end }
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then require('packer').sync() end
end)

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
