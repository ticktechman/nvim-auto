# nvim-auto

auto install deps for different PL(programming language)

# from scratch

- recommended LSP toolkits(LS, LINTTER, FORMATTER)
- auto install toolkits after you open a file
- install all packages under ~/.config/nvim/.packages(lazy, mason)

# language-server name and package name

mason use different language-server name and package name.
you can use the following commands to translate

```bash
cd ~/.config/nvim/.packages/mason/registries/github/mason-org/mason-registry
jq -r '.[] | select(.neovim?.lspconfig?) | [.name, .neovim.lspconfig] | @tsv' registry.json | column -t
```
