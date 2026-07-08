# Neovim Configuration

A personal Neovim setup managed with [lazy.nvim](https://github.com/folke/lazy.nvim).

- **Structure:** Monolithic `init.lua`
- **Theme:** [Catppuccin](https://github.com/catppuccin/nvim) (mocha)
- **Language support:** Go, TypeScript/JavaScript, Lua, Terraform, Docker, Markdown

## Requirements

- Neovim `>= 0.11` (uses native LSP `vim.lsp.config` / `vim.lsp.enable`)
- Git (for plugin bootstrapping and Mason)
- A [Nerd Font](https://www.nerdfonts.com/) for icons

## Install

```sh
git clone git@github.com:fabioesposito/nvim-config.git ~/.config/nvim
```

On first launch, lazy.nvim bootstraps itself and installs all plugins. Tools
(listed in `mason-tool-installer`) such as `gopls`, `prettier`, `stylua`, and
`golangci-lint` are installed automatically via [Mason](https://github.com/mason-org/mason.nvim).

## Features

- **Native LSP** via `nvim-lspconfig` + Mason, with format-on-save and inlay hints
- **Completion** with `nvim-cmp` + LuaSnip
- **Formatting** (conform.nvim) and **linting** (nvim-lint)
- **Treesitter** highlighting, indenting, and incremental selection
- **Telescope** fuzzy finding, **Neo-tree** file explorer, **Oil** directory editing
- **Flash** navigation, **Gitsigns** + **LazyGit** integration
- **Statusline** (lualine), **Trouble** diagnostics, **Snacks** utilities, **which-key** hints

## Key mappings

| Key | Action |
| --- | --- |
| `<Space>` | Leader key |
| `<C-n>` | Toggle file tree |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep (Telescope) |
| `<leader>tt` | Trouble diagnostics |
| `<leader>lg` | LazyGit |
| `gd` / `gr` / `K` | LSP definition / references / hover |
| `<leader>ca` / `<leader>cr` | LSP code action / rename |
| `s` | Flash jump |
| `-` | Open parent directory (Oil) |

Run `:Telescope keymaps` or press `<Space>` to explore all mappings via which-key.

## Updating

```vim
:Lazy update    " update plugins
:MasonUpdate    " update Mason
```
