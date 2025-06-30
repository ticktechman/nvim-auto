-------------------------------------------------------------------------------
--
--       filename: language.lua
--    description:
--        created: 2025/06/30
--         author: ticktechman
--
-------------------------------------------------------------------------------

local conf_path = vim.fn.stdpath("config")
local map = vim.keymap.set

local M = {}

M.data = {
  lua = {
    lang_server = "lua-language-server",
    formatter = "stylua",
  },
  python = {
    lang_server = "pyright",
    formatter = "black",
    linter = "ruff",
  },
  javascript = {
    lang_server = "typescript-language-server",
    formatter = "prettierd",
    linter = "eslint_d",
  },
  typescript = {
    lang_server = "typescript-language-server",
    formatter = "prettierd",
    linter = "eslint_d",
  },
  rust = {
    lang_server = "rust_analyzer",
    formatter = "rustfmt",
  },
  go = {
    lang_server = "gopls",
    formatter = "gofumpt",
    linter = "golangci_lint",
  },
  markdown = {
    lang_server = "marksman",
    formatter = "prettierd",
  },
  json = {
    lang_server = "json-lsp",
    formatter = "prettierd",
  },
  c = {
    lang_server = "clangd",
    formatter = "clang-format",
    linter = "clang-tidy",
  },
  cpp = {
    lang_server = "clangd",
    formatter = "clang-format",
    linter = "clang-tidy",
  },
  sh = {
    lang_server = "bash-language-server",
    formatter = "shfmt",
    linter = "shellcheck",
  },
}

M.for_conform = function()
  local c = {}
  for k, v in pairs(M.data) do
    c[k] = { v.formatter }
  end
  return c
end

M.enable_all_servers = function()
  local servers = {}
  local mappings = require("mason-lspconfig.mappings").get_mason_map()
  local pkg2lsp = mappings.package_to_lspconfig
  for _, v in pairs(M.data) do
    if not servers[v.lang_server] then
      local lspname = pkg2lsp[v.lang_server]
      if lspname then
        vim.lsp.enable(lspname)
      end
    end
  end
end

M.ensure_installed = function()
  require("mason").setup({ install_root_dir = vim.g.install_home_dir .. "/mason" })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
      local registry = require("mason-registry")
      local ft = vim.bo[args.buf].filetype
      local spec = M.data[ft]
      if not spec then
        return
      end

      local install = function(name)
        local ok, pkg = pcall(registry.get_package, name)
        if ok and not pkg:is_installed() then
          pkg:install()
        end
      end

      for _, tool in pairs(spec) do
        if type(tool) == "string" then
          install(tool)
        end
      end
    end,
  })
end
local language = M

return {
  -----------------------------
  -- treesitter for syntax highlight
  -----------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = { "vim", "lua", "vimdoc" },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -----------------------------
  -- mason for language-server, linter, formatter
  -----------------------------
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup({ install_root_dir = vim.g.install_home_dir .. "/mason" })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },

    config = function()
      -- lua ls config
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local function opts(desc)
            return { buffer = args.buf, desc = "LSP " .. desc }
          end

          map("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
          map("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
          map("n", "gr", vim.lsp.buf.references, opts("Go to definition"))
          map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts("Add workspace folder"))
          map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts("Remove workspace folder"))

          map("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts("List workspace folders"))

          map("n", "<leader>D", vim.lsp.buf.type_definition, opts("Go to type definition"))
        end,
      })

      local lua_lsp_settings = {
        Lua = {
          workspace = {
            library = {
              vim.fn.expand("$VIMRUNTIME/lua"),
              vim.g.install_home_dir .. "/lazy/lazy.nvim/lua/lazy",
              "${3rd}/luv/library",
            },
          },
        },
      }
      vim.lsp.config("lua_ls", { settings = lua_lsp_settings })
      language.enable_all_servers()
      language.ensure_installed()

      -- diagnostic messages config
      local x = vim.diagnostic.severity
      vim.diagnostic.config({
        virtual_text = { prefix = "" },
        signs = { text = { [x.ERROR] = "󰅙", [x.WARN] = "", [x.INFO] = "󰋼", [x.HINT] = "󰌵" } },
        underline = true,
        float = { border = "single" },
      })
    end,
  },

  ----------------------------
  -- auto format when save it
  ----------------------------
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("conform").setup({
        formatters_by_ft = language.for_conform(),
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  ----------------------------
  -- auto complete
  ----------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      {
        -- snippet plugin
        "L3MON4D3/LuaSnip",
        dependencies = "rafamadriz/friendly-snippets",
        opts = { history = true, updateevents = "TextChanged,TextChangedI" },
        config = function(_, opts)
          require("luasnip").config.set_config(opts)
          -- vscode format
          require("luasnip.loaders.from_vscode").load()
          require("luasnip.loaders.from_vscode").lazy_load({ paths = { conf_path .. "/snippets" } })

          -- snipmate format
          require("luasnip.loaders.from_snipmate").load()
          require("luasnip.loaders.from_snipmate").lazy_load({ paths = vim.g.snipmate_snippets_path or "" })

          -- lua format
          require("luasnip.loaders.from_lua").load()
          require("luasnip.loaders.from_lua").lazy_load({ paths = vim.g.lua_snippets_path or "" })
        end,
      },

      -- autopairing of (){}[] etc
      {
        "windwp/nvim-autopairs",
        opts = {
          fast_wrap = {},
          disable_filetype = { "TelescopePrompt", "vim" },
        },
        config = function(_, opts)
          require("nvim-autopairs").setup(opts)

          -- setup cmp for autopairs
          local cmp_autopairs = require("nvim-autopairs.completion.cmp")
          require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
      },

      -- cmp sources plugins
      {
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
      },
    },

    config = function()
      local cmp = require("cmp")
      cmp.setup({
        completion = { completeopt = "menu,menuone" },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },

        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },

        mapping = {
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),

          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif require("luasnip").expand_or_jumpable() then
              require("luasnip").expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif require("luasnip").jumpable(-1) then
              require("luasnip").jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },

        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "nvim_lua" },
          { name = "path" },
        },
      })
    end,
  },
}

-------------------------------------------------------------------------------
