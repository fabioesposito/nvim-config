# Neovim Configuration

A personal Neovim setup managed with [lazy.nvim](https://github.com/folke/lazy.nvim).

- **Structure:** Monolithic `init.lua`
- **Theme:** [Catppuccin](https://github.com/catppuccin/nvim) (mocha)
- **Language support:** Go, TypeScript/JavaScript, Lua, Terraform, Docker, Markdown

## Requirements

- Neovim `>= 0.11` (uses native LSP `vim.lsp.config` / `vim.lsp.enable`; developed on 0.12)
- Git (for plugin bootstrapping and Mason)
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- [ripgrep](https://github.com/BurntSushi/ripgrep) for Telescope live grep / file finding
- A C compiler (`gcc`/`clang`) for Treesitter parsers and `telescope-fzf-native`

Optional: [lazygit](https://github.com/jesseduffield/lazygit) (for `<leader>lg` / `<leader>gg`),
`terraform` CLI (for `terraform fmt`; falls back to the LSP otherwise).

## Install

```sh
git clone git@github.com:fabioesposito/nvim-config.git ~/.config/nvim
```

On first launch, lazy.nvim bootstraps itself and installs all plugins. Tools
(listed in `mason-tool-installer`) such as `gopls`, `prettier`, `stylua`, and
`golangci-lint` are installed automatically via [Mason](https://github.com/mason-org/mason.nvim).

## Features

- **Native LSP** via `nvim-lspconfig` + Mason, with inlay hints and completion
  capabilities applied before any client attaches
- **Completion** with `nvim-cmp` + LuaSnip + [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
- **Formatting** (conform.nvim, format-on-save with LSP fallback, toggleable)
  and **linting** (nvim-lint)
- **Treesitter** highlighting and indentation
- **Telescope** fuzzy finding (with the native fzf sorter), **Neo-tree** file
  explorer, **Oil** directory editing
- **Flash** navigation, **Gitsigns** + **LazyGit** integration
- **Statusline** (lualine), **Trouble** diagnostics, **Snacks** utilities, **which-key** hints
- **lazydev.nvim** for full Neovim API completion when editing Lua config

## Key mappings

| Key | Action |
| --- | --- |
| `<Space>` | Leader key |
| `<C-n>` | Toggle file tree |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep (Telescope) |
| `<leader>tt` | Trouble diagnostics |
| `<leader>lg` / `<leader>gg` | LazyGit |
| `gd` / `gr` / `K` | LSP definition / references / hover |
| `<C-s>` (insert) | LSP signature help (Neovim default) |
| `<leader>ca` / `<leader>cr` | LSP code action / rename |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>F` | Format buffer |
| `<leader>uf` | Toggle format-on-save |
| `<leader>uh` | Toggle inlay hints |
| `<leader>bd` / `<leader>bo` | Delete buffer / close other buffers |
| `<leader>tf` or `<C-/>` | Toggle terminal |
| `<Esc><Esc>` (terminal) | Exit terminal mode |
| `s` | Flash jump |
| `-` | Open parent directory (Oil) |

Run `:Telescope keymaps` or press `<Space>` to explore all mappings via which-key.

Format-on-save can also be controlled with `:FormatDisable` (`:FormatDisable!`
for the current buffer only) and `:FormatEnable`.

## Updating

```vim
:Lazy update    " update plugins
:MasonUpdate    " update Mason
```