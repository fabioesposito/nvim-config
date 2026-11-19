--[[
  Neovim Configuration
  =====================
  Plugin manager: lazy.nvim
  Structure:       monolithic (single init.lua)
  Theme:           catppuccin
--]]

-- Bootstrap lazy.nvim -------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Options --------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.clipboard = "unnamedplus"

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true
vim.opt.breakindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
local undodir = vim.fn.stdpath("data") .. "/undo"
vim.fn.mkdir(undodir, "p")
vim.opt.undodir = undodir

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.updatetime = 200
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"
vim.opt.inccommand = "split"
vim.opt.wrap = false
vim.opt.confirm = true
vim.opt.showmode = false -- mode is shown in lualine
vim.opt.laststatus = 3 -- global statusline
vim.opt.winborder = "rounded" -- rounded borders for LSP/diagnostic floats
vim.opt.wildoptions = "pum" -- cmdline completion in a popup menu
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.diffopt:append("linematch:60") -- better diff alignment
vim.g.markdown_recommended_style = 0 -- keep 2-space indent in markdown

-- General keymaps ------------------------------------------------------------
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move to left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move to right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move to upper window" })

-- Keep visual selection when indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Move lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

-- Exit terminal mode with a double escape (single Esc reaches the terminal app)
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Buffer / file operations
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>Q", "<cmd>quitall!<CR>", { desc = "Force quit all" })
vim.keymap.set("n", "<leader>x", "<cmd>x<CR>", { desc = "Save and quit" })
vim.keymap.set("n", "<leader>bD", "<cmd>bdelete!<CR>", { desc = "Force close buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Close other buffers" })

-- General autocmds -------------------------------------------------------------
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("UserYankHighlight", { clear = true }),
  callback = function() vim.hl.on_yank({ timeout = 200 }) end,
  desc = "Briefly highlight yanked text",
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("UserRestoreCursor", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then return end
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
  desc = "Restore cursor position when reopening a file",
})

-- Treesitter highlighting / indentation ---------------------------------------
-- nvim-treesitter (main branch) does not enable features automatically.
-- Start the built-in treesitter highlighter for any filetype that has a parser.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitter", {}),
  callback = function(args)
    if pcall(vim.treesitter.start, args.buf) then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Diagnostics ------------------------------------------------------------------
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

-- LSP setup (runs immediately, before any buffer loads) -----------------------
-- Capabilities are applied to every server via vim.lsp.config("*") when
-- cmp-nvim-lsp loads below (eagerly, before any client attaches).
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gr", vim.lsp.buf.references, "Go to references")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    -- Signature help: Neovim >= 0.11 maps insert-mode <C-s> natively.
    -- (Normal-mode <C-k> stays free for window navigation.)
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
    map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
    map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
    map("n", "<leader>cl", "<cmd>LspInfo<CR>", "LSP info")
    map("n", "<leader>uh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
    end, "Toggle inlay hints")

    -- Format-on-save is handled by conform.nvim (with LSP fallback), so no
    -- BufWritePre formatting autocmd here -- it would format every file twice.

    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
})

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      gofumpt = true,
      analyses = { unusedparams = true, unreachable = true, unusedvariable = true },
      staticcheck = true,
    },
  },
})

vim.lsp.config("ts_ls", {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayFunctionLikeReturnTypeHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayFunctionLikeReturnTypeHints = true,
      },
    },
  },
})

-- marksman, terraformls and dockerls work with the nvim-lspconfig defaults.

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})
-- lazydev.nvim (below, loaded for Lua files) adds the Neovim runtime library
-- to lua_ls for proper completion of the vim API.

vim.lsp.enable({ "gopls", "ts_ls", "marksman", "terraformls", "dockerls", "lua_ls" })
-- END LSP setup ---------------------------------------------------------------

-- Plugins --------------------------------------------------------------------
require("lazy").setup({
  --------------------------------------------------------------------------
  -- Theme
  --------------------------------------------------------------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      integrations = {
        cmp = true,
        flash = true,
        gitsigns = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = { enabled = true },
        neo_tree = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        which_key = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  --------------------------------------------------------------------------
  -- Treesitter
  --------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false, -- upstream: plugin does not support lazy-loading
    config = function()
      require("nvim-treesitter").install({
        "bash", "c", "css", "dockerfile", "eex", "elixir", "go", "gomod",
        "gosum", "hcl", "heex", "html", "javascript", "json", "lua", "make",
        "markdown", "markdown_inline", "python", "regex", "sql", "terraform",
        "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
      })
    end,
  },

  --------------------------------------------------------------------------
  -- Mason (LSP/formatter/linter installer)
  --------------------------------------------------------------------------
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
  },
  -- Servers are enabled manually via vim.lsp.enable() above and installed by
  -- mason-tool-installer, so mason-lspconfig is not needed.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "gopls", "typescript-language-server", "marksman", "terraform-ls",
        "dockerfile-language-server", "lua-language-server",
        "gofumpt", "goimports", "prettier", "stylua",
        "golangci-lint", "eslint_d", "markdownlint", "tflint", "hadolint",
      },
    },
  },

  --------------------------------------------------------------------------
  -- Completion
  --------------------------------------------------------------------------
  {
    -- Loaded eagerly so completion capabilities are set via vim.lsp.config("*")
    -- BEFORE any LSP client attaches (doing this on InsertEnter is too late).
    "hrsh7th/cmp-nvim-lsp",
    lazy = false,
    config = function()
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
      },
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      vim.keymap.set({ "i", "s" }, "<C-k>", function()
        if luasnip.expand_or_jumpable() then luasnip.expand_or_jump() end
      end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<C-j>", function()
        if luasnip.jumpable(-1) then luasnip.jump(-1) end
      end, { silent = true })

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(entry, item)
            local max_width = 50
            if #item.abbr > max_width then
              item.abbr = vim.fn.strcharpart(item.abbr, 0, max_width - 1) .. "…"
            end
            return item
          end,
        },
      })
    end,
  },

  --------------------------------------------------------------------------
  -- Formatting (conform.nvim)
  --------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>F",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
      {
        "<leader>uf",
        function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify("Format on save " .. (vim.g.disable_autoformat and "disabled" or "enabled"))
        end,
        desc = "Toggle format on save",
      },
    },
    init = function()
      -- Use conform for gq; FormatEnable/FormatDisable toggle format-on-save
      -- globally (FormatDisable! for the current buffer only).
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = "Disable format-on-save", bang = true })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Re-enable format-on-save" })
    end,
    opts = {
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
      formatters_by_ft = {
        go = { "gofumpt", "goimports" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        terraform = { "terraform_fmt" },
        lua = { "stylua" },
        yaml = { "prettier" },
        -- dockerfile handled by hadolint (lint only), no formatter
      },
      formatters = {
        terraform_fmt = {
          command = "terraform",
          args = { "fmt", "-" },
        },
      },
    },
  },

  --------------------------------------------------------------------------
  -- Linting (nvim-lint)
  --------------------------------------------------------------------------
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        go = { "golangcilint" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        markdown = { "markdownlint" },
        terraform = { "tflint" },
        dockerfile = { "hadolint" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("UserLint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  --------------------------------------------------------------------------
  -- File tree
  --------------------------------------------------------------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<C-n>", "<cmd>Neotree toggle<CR>", desc = "Toggle file tree" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      window = { width = 35 },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { ".DS_Store", "thumbs.db" },
        },
      },
    },
  },

  --------------------------------------------------------------------------
  -- Fuzzy finder
  --------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files hidden=true<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
      { "<leader>fr", "<cmd>Telescope resume<CR>", desc = "Resume last search" },
      { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<CR>", desc = "Workspace symbols" },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        path_display = { "truncate" },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
      },
      pickers = {
        find_files = {
          -- rg is already required for live_grep; faster than find and
          -- respects .gitignore while still showing hidden files.
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git" },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      pcall(require("telescope").load_extension, "fzf")
    end,
  },

  --------------------------------------------------------------------------
  -- Flash (fast movement, supersedes leap)
  --------------------------------------------------------------------------
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      labels = "asdfghjklqwertyuiopzxcvbnm",
      modes = {
        char = { enabled = true },
        search = { enabled = true },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Flash remote" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Flash treesitter search" },
    },
  },

  --------------------------------------------------------------------------
  -- Git signs
  --------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "" },
        change = { text = "" },
        delete = { text = "_" },
        topdelete = { text = "" },
        changedelete = { text = "~" },
        untracked = { text = "" },
      },
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      attach_to_untracked = false,
      current_line_blame = false,
      current_line_blame_opts = { delay = 1000 },
      sign_priority = 6,
      update_debounce = 200,
      status_formatter = nil,
      max_file_length = 40000,
    },
    keys = {
      { "]c", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", expr = true, desc = "Next hunk" },
      { "[c", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", expr = true, desc = "Previous hunk" },
      { "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", desc = "Stage hunk" },
      { "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", desc = "Reset hunk" },
      { "<leader>hS", "<cmd>Gitsigns stage_buffer<CR>", desc = "Stage buffer" },
      { "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "Undo stage hunk" },
      { "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", desc = "Preview hunk" },
      { "<leader>hb", "<cmd>Gitsigns blame_line<CR>", desc = "Blame line" },
      { "<leader>ht", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "Toggle blame" },
      { "<leader>hd", "<cmd>Gitsigns diffthis<CR>", desc = "Diff this" },
    },
  },

  --------------------------------------------------------------------------
  -- LazyGit
  --------------------------------------------------------------------------
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>lg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
      { "<leader>lgf", "<cmd>LazyGitFilter<CR>", desc = "LazyGit filter" },
      { "<leader>lgh", "<cmd>LazyGitCurrentFile<CR>", desc = "LazyGit current file" },
    },
  },

  --------------------------------------------------------------------------
  -- Statusline
  --------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "catppuccin/nvim" },
    opts = {
      options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { "alpha", "dashboard", "neo-tree", "lazy" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          {
            "filename",
            file_status = true,
            path = 1, -- relative
          },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  --------------------------------------------------------------------------
  -- Which-key
  --------------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        -- <leader> groups (only real prefixes; direct maps like <leader>w
        -- are described by their own `desc`)
        { "<leader>b", group = "Buffers" },
        { "<leader>c", group = "Code / LSP" },
        { "<leader>f", group = "Find / Telescope" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Hunks / Gitsigns" },
        { "<leader>l", group = "LazyGit" },
        { "<leader>s", group = "Search / Todo" },
        { "<leader>t", group = "Trouble / Terminal" },
        { "<leader>u", group = "UI" },
        -- LSP navigation (g prefix)
        { "g", group = "Go to (LSP)" },
        -- Diagnostics navigation
        { "[", group = "Previous" },
        { "]", group = "Next" },
      },
    },
  },

  --------------------------------------------------------------------------
  -- Lua development (Neovim API completion / diagnostics via lua_ls)
  --------------------------------------------------------------------------
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  --------------------------------------------------------------------------
  -- Auto pairs
  --------------------------------------------------------------------------
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    version = false,
    config = function()
      require("mini.pairs").setup()
    end,
  },

  --------------------------------------------------------------------------
  -- Surround
  --------------------------------------------------------------------------
  {
    "echasnovski/mini.surround",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.surround").setup({
        mappings = {
          add = "sa",
          delete = "ds",
          replace = "cs",
          find = "",
          find_left = "",
          highlight = "",
          update_n_lines = "",
          suffix_last = "",
          suffix_next = "",
        },
        n_lines = 20,
        search_method = "cover_or_next",
      })
      vim.keymap.set("x", "sa", "<cmd>lua MiniSurround.add('visual')<CR>")
    end,
  },

  --------------------------------------------------------------------------
  -- Comment
  --------------------------------------------------------------------------
  {
    "echasnovski/mini.comment",
    version = false,
    event = "VeryLazy",
    config = function()
      require("ts_context_commentstring").setup({ enable_autocmd = false })
      require("mini.comment").setup({
        options = {
          custom_commentstring = function()
            return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
          end,
        },
      })
    end,
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
  },

  --------------------------------------------------------------------------
  -- Trouble (diagnostics list)
  --------------------------------------------------------------------------
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>tt", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<leader>tT", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics (Trouble)" },
      { "<leader>ts", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols (Trouble)" },
      { "<leader>tl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP definitions/references (Trouble)" },
      { "<leader>tL", "<cmd>Trouble loclist toggle<CR>", desc = "Location list (Trouble)" },
      { "<leader>tQ", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix list (Trouble)" },
      {
        "[T",
        function() require("trouble").prev({ skip_groups = true, jump = true }) end,
        desc = "Previous trouble item",
      },
      {
        "]T",
        function() require("trouble").next({ skip_groups = true, jump = true }) end,
        desc = "Next trouble item",
      },
    },
    opts = {
      auto_close = false,
      auto_open = false,
      auto_preview = true,
      auto_fold = false,
      use_diagnostic_signs = true,
    },
  },

  --------------------------------------------------------------------------
  -- Oil (edit directories as buffers)
  --------------------------------------------------------------------------
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory (Oil)" },
      { "<leader>-", "<cmd>Oil --float<CR>", desc = "Open parent directory floating (Oil)" },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          return name == ".." or name == ".git"
        end,
      },
      float = {
        padding = 2,
        max_width = 80,
        max_height = 30,
      },
      win_options = {
        wrap = true,
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  --------------------------------------------------------------------------
  -- Snacks (notifications, indentation, bigfile, etc.)
  --------------------------------------------------------------------------
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      quickfile = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      terminal = {
        enabled = true,
        win = { style = "minimal" },
      },
    },
    keys = {
      {
        "<leader>un",
        function() Snacks.notifier.hide() end,
        desc = "Dismiss all notifications",
      },
      {
        "<leader>gg",
        function() Snacks.lazygit() end,
        desc = "LazyGit (Snacks)",
      },
      {
        "<leader>gb",
        function() Snacks.git.blame_line() end,
        desc = "Git blame line (Snacks)",
      },
      {
        "<leader>gB",
        function() Snacks.gitbrowse() end,
        desc = "Git browse (Snacks)",
      },
      {
        "<leader>tf",
        function() Snacks.terminal.toggle() end,
        desc = "Toggle terminal",
      },
      {
        "<leader>.",
        function() Snacks.scratch() end,
        desc = "Scratch buffer",
      },
      {
        "<leader>bd",
        function() Snacks.bufdelete() end,
        desc = "Delete buffer (Snacks)",
      },
      {
        "<c-/>",
        function() Snacks.terminal.toggle() end,
        desc = "Toggle terminal",
      },
    },
  },

  --------------------------------------------------------------------------
  -- Todo comments
  --------------------------------------------------------------------------
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>st", "<cmd>TodoTelescope<CR>", desc = "Todo list (Telescope)" },
      { "<leader>sT", "<cmd>TodoQuickFix<CR>", desc = "Todo list (QuickFix)" },
      { "]t", "<cmd>lua require('todo-comments').jump_next()<CR>", desc = "Next todo comment" },
      { "[t", "<cmd>lua require('todo-comments').jump_prev()<CR>", desc = "Previous todo comment" },
    },
    opts = {
      keywords = {
        TODO = { icon = " ", color = "info" },
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", color = "hint", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
  },
}, {
  -- lazy.nvim global options
  ui = { border = "rounded" },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})
