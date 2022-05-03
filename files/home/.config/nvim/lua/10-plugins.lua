local fn = vim.fn

-- automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- install your plugins here
return packer.startup(function(use)
  use "wbthomason/packer.nvim" -- have packer manage itself
  use "nvim-lua/plenary.nvim"  -- useful lua functions used by lots of plugins

  use "lukas-reineke/indent-blankline.nvim"
  use "mhinz/vim-startify"
  use "Raimondi/delimitMate"
  use "luochen1990/rainbow"
  use "vim-syntastic/syntastic"

  use "morhetz/gruvbox"
  use "kyazdani42/nvim-web-devicons"
  use "nvim-lualine/lualine.nvim"

  use "neovim/nvim-lspconfig" -- Collection of common configurations for the Nvim LSP client
  use "hrsh7th/nvim-cmp"      -- Completion framework
  use "hrsh7th/cmp-nvim-lsp"  -- LSP completion source for nvim-cmp
  use "hrsh7th/cmp-vsnip"     -- Snippet completion source for nvim-cmp
  use "hrsh7th/cmp-path"      -- Other usefull completion sources
  use "hrsh7th/cmp-buffer"

  -- Snippet engine
  use "hrsh7th/vim-vsnip"

  -- Fuzzy finder
  -- Optional
  use "nvim-lua/popup.nvim"
  use "nvim-telescope/telescope.nvim"

  -- automatically set up your configuration after cloning packer.nvim
  -- put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
