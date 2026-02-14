local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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

vim.g.mapleader = " "

-- 2. Configuration & Plugins
require("lazy").setup({
  -- Colorscheme (LazyVim default)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight")
    end
  },

        -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require('telescope').setup({
        defaults = {
          vimgrep_arguments = {
            'rg', '--color=never', '--no-heading', '--with-filename',
            '--line-number', '--column', '--smart-case',
          },
        },
      })
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>/', builtin.live_grep, {})
    end
  },

  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")
    end
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter').setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc" },
        highlight = { enable = true },
      })
    end
  },

  { "neovim/nvim-lspconfig" },

  -- Bufferline (tab bar for open buffers)
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup()
    end
  },

  -- Session persistence
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    config = function()
      require("persistence").setup()
      vim.keymap.set('n', '<leader>qs', function() require("persistence").load() end)
      vim.keymap.set('n', '<leader>ql', function() require("persistence").load({ last = true }) end)
    end
  },

  -- Auto-detect indentation from file contents
  {
    "NMAC427/guess-indent.nvim",
    config = function()
      require("guess-indent").setup()
    end
  },
})

-- LSP Configuration (Neovim 0.11+ native API)
vim.lsp.config.clangd = {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
}
vim.lsp.enable("clangd")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
    vim.keymap.set('n', '<leader>cf', function() vim.lsp.buf.format() end, opts)
    vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, opts)

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "clangd" then
      vim.keymap.set('n', 'gs', function()
        vim.lsp.buf_request(0, 'textDocument/switchSourceHeader', vim.lsp.util.make_text_document_params(), function(err, result)
          if result then vim.cmd.edit(vim.uri_to_fname(result)) end
        end)
      end, opts)
    end
  end,
})

-- 3. Plugin Settings
-- General Vim Settings
vim.opt.number = true         -- Show line numbers
vim.opt.termguicolors = true   -- Enable 24-bit RGB color
vim.opt.ignorecase = true      -- Case-insensitive search
vim.opt.smartcase = true       -- Case-sensitive when uppercase is used
vim.opt.undofile = true        -- Persist undo history across restarts
vim.opt.tabstop = 4            -- Display tabs as 4 spaces
vim.opt.shiftwidth = 4         -- Indent with 4 spaces
vim.opt.expandtab = true       -- Use spaces instead of tabs

vim.keymap.set('n', '<leader>qq', '<cmd>qa<cr>')
vim.keymap.set('n', '<leader>wq', '<cmd>wq<cr>')
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<cr>')
vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>')
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<cr>')

