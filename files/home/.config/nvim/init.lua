-- NeoVIM Main Configuration

local fn = vim.fn
local options = {
  backup = false,
  clipboard = "unnamedplus",
  cmdheight = 2,
  completeopt = { "menuone", "noselect" },
  conceallevel = 0,
  fileencoding = "utf-8",
  hlsearch = true,
  ignorecase = true,
  mouse = "a",
  pumheight = 10,
  showmode = false,
  showtabline = 2,
  smartcase = true,
  smartindent = true,
  splitbelow = true,
  splitright = true,
  swapfile = false,
  termguicolors = true,
  timeoutlen = 100,
  undofile = true,
  updatetime = 300,
  writebackup = false,
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
  cursorline = true,
  number = true,
  relativenumber = false,
  numberwidth = 4,
  signcolumn = "yes",
  wrap = false,
  scrolloff = 8,
  sidescrolloff = 8,
  guifont = "monospace:h14",
}

vim.opt.shortmess:append "c"
for k, v in pairs(options) do vim.opt[k] = v end

-- automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim",
    install_path
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then return end

-- have packer use a popup window
packer.init { display = { open_fn = function() return require("packer.util").float { border = "rounded" } end, }, }

-- install your plugins here
packer.startup(function(use)
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
  use "nvim-lua/popup.nvim"
  use "nvim-telescope/telescope.nvim"

  -- automatically set up your configuration after cloning packer.nvim
  -- put this at the end after all plugins
  if PACKER_BOOTSTRAP then require("packer").sync() end
end)

vim.cmd[[
  syntax enable
  if (has("termguicolors"))
    set termguicolors
  endif

  if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
  endif

  set background=dark
  colorscheme gruvbox

  let g:gruvbox_italic = 1
  let g:syntastic_check_on_open = 1
  let g:rainbow_active = 1
]]

local status_ok, lualine = pcall(require, "lualine")
if not status_ok then return end

lualine.setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
    component_separators = { left = ' ', right = ' '},
    section_separators = { left = '  ', right = '  '},
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

