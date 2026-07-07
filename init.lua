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
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

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
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Buffer / file operations
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>Q", "<cmd>quitall!<CR>", { desc = "Force quit all" })
vim.keymap.set("n", "<leader>x", "<cmd>x<CR>", { desc = "Save and quit" })
vim.keymap.set("n", "<leader>bD", "<cmd>bdelete!<CR>", { desc = "Force close buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bo", "<cmd>%bd|e#<CR>", { desc = "Close other buffers" })

-- LSP setup (runs immediately, before any buffer loads) -----------------------
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
    map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
    map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    map("n", "<leader>cl", "<cmd>LspInfo<CR>", "LSP info")

    if client:supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("UserLspFormat", { clear = true }),
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end

    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
})

-- Base capabilities (upgraded later when nvim-cmp loads)
local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.mod", "go.work", ".git" },
  capabilities = lsp_capabilities,
  settings = {
    gopls = {
      gofumpt = true,
      analyses = { unusedparams = true, unreachable = true, unusedvariable = true },
      staticcheck = true,
    },
  },
})
vim.lsp.enable("gopls")

vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  capabilities = lsp_capabilities,
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
vim.lsp.enable("ts_ls")

vim.lsp.config("marksman", {
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx" },
  root_markers = { ".marksman.toml", ".git" },
  capabilities = lsp_capabilities,
})
vim.lsp.enable("marksman")

vim.lsp.config("terraformls", {
  cmd = { "terraform-ls", "serve" },
  filetypes = { "terraform", "tf", "hcl" },
  root_markers = { ".terraform", ".git" },
  capabilities = lsp_capabilities,
})
vim.lsp.enable("terraformls")

vim.lsp.config("dockerls", {
  cmd = { "docker-langserver", "--stdio" },
  filetypes = { "dockerfile" },
  root_markers = { "Dockerfile", "docker-compose.yml", ".dockerignore", ".git" },
  capabilities = lsp_capabilities,
})
vim.lsp.enable("dockerls")

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", ".git" },
  capabilities = lsp_capabilities,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})
vim.lsp.enable("lua_ls")
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
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = { enabled = true },
        navic = { enabled = true },
        neotest = true,
        neo_tree = true,
        noice = true,
        notify = true,
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
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSUpdate" },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "bash", "c", "css", "dockerfile", "go", "gomod", "gosum",
          "hcl", "html", "javascript", "json", "lua", "make", "markdown",
          "markdown_inline", "python", "regex", "sql", "terraform",
          "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<M-space>",
          },
        },
      })
    end,
  },

  --------------------------------------------------------------------------
  -- Mason (LSP/formatter/linter installer)
  --------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = "Mason",
    opts = {
      ensure_installed = {
        -- LSP servers
        "gopls", "typescript-language-server", "marksman", "terraform-ls",
        "dockerfile-language-server", "lua-language-server",
        -- formatters
        "gofumpt", "goimports", "prettier", "stylua",
        -- linters
        "golangci-lint", "eslint_d", "markdownlint", "tflint", "hadolint",
      },
    },
  },

  --------------------------------------------------------------------------
  -- Completion
  --------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Upgrade LSP capabilities with cmp support
      local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )
      local servers = { "gopls", "ts_ls", "marksman", "terraformls", "dockerls", "lua_ls" }
      for _, s in ipairs(servers) do
        vim.lsp.config(s, { capabilities = cmp_capabilities })
      end

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
        function() require("conform").format({ async = true }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      format_on_save = function(bufnr)
        -- Disable format-on-save for files with special characters, etc.
        -- Return a table for conform to use
        return { timeout_ms = 2000, lsp_fallback = true }
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
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
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
    },
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
        -- <leader> groups
        { "<leader>b", group = "Buffers" },
        { "<leader>c", group = "Code / LSP" },
        { "<leader>f", group = "Find / Telescope" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Hunks / Gitsigns" },
        { "<leader>l", group = "LazyGit" },
        { "<leader>s", group = "Search / Todo" },
        { "<leader>t", group = "Trouble / Terminal" },
        { "<leader>u", group = "UI" },
        { "<leader>w", group = "Save" },
        { "<leader>q", group = "Quit" },
        { "<leader>Q", group = "Force quit all" },
        { "<leader>x", group = "Save + quit" },
        -- LSP navigation (g prefix)
        { "g", group = "Go to (LSP)" },
        -- Diagnostics navigation
        { "[", group = "Previous" },
        { "]", group = "Next" },
        -- Flash movement
        { "s", group = "Flash jump" },
        { "S", group = "Flash treesitter" },
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
          add = "ys",
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
      vim.keymap.set("x", "ys", "<cmd>lua MiniSurround.add('visual')<CR>")
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
