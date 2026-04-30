vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = ""
vim.keymap.set({ "", "i" }, "<up>", "<nop>")
vim.keymap.set({ "", "i" }, "<down>", "<nop>")
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.autowrite = true

vim.keymap.set('n', '<leader>jq', ':%!jq .<CR>', { desc = 'Format JSON with jq' })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "lua", "c", "markdown" },
        highlight = { enable = true },
      })
    end,
  },

  -- LSP
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },

  -- Autocomplete
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },

  -- File finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- AI autocomplete
  { "supermaven-inc/supermaven-nvim", config = true },

  -- Auto close brackets
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

  -- Git
  { "kdheepak/lazygit.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Theme
  { "folke/tokyonight.nvim" },

  -- File tree
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Lualine
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Git signs
  { "lewis6991/gitsigns.nvim", config = true },

  -- Indent guides
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", config = true },

  -- Commenting
  { "numToStr/Comment.nvim", config = true },

  -- Markdown rendering
  { "MeanderingProgrammer/render-markdown.nvim", config = true },

  -- SQL / database UI
  { "tpope/vim-dadbod" },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    config = function()
      vim.g.db_ui_save_location = vim.fn.expand("~/.local/share/nvim/db_ui")
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
  { "kristijanhusak/vim-dadbod-completion", dependencies = { "tpope/vim-dadbod" } },
})

vim.cmd("colorscheme tokyonight")

-- LSP setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "clangd" },
})

vim.lsp.config("clangd", {
	cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/clangd") },
	filetypes = { "c", "cpp", "objc", "objcpp", "h", "hpp" },
})
vim.lsp.enable("clangd")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})

local cmp = require("cmp")
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = "supermaven" },
    { name = "nvim_lsp" },
    { name = "vim-dadbod-completion" },
  }),
})
 
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", function()
	telescope.find_files({ hidden = true})
end)
vim.keymap.set("n", "<leader>fg", telescope.live_grep)
vim.keymap.set("n", "<leader>lg", ":LazyGit<CR>")

require("nvim-tree").setup()
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>db", ":DBUIToggle<CR>")

require("lualine").setup()
