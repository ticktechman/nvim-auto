-------------------------------------------------------------------------------
--
--       filename: ui.lua
--    description:
--        created: 2025/06/30
--         author: ticktechman
--
-------------------------------------------------------------------------------

local function lang_server_name()
  local clients = vim.lsp.get_clients({
    bufnr = vim.api.nvim_get_current_buf(),
  })
  local names = ""

  for _, client in pairs(clients) do
    if client.name ~= "null-ls" then
      names = "[" .. client.name .. "]"
      break
    end
  end

  if #names == 0 then
    return ""
  end
  return "  " .. names
end

return {
  ----------------------------
  -- file browser
  ----------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local api = require("nvim-tree.api")
      local function attach(bufnr)
        local opts = function()
          return { buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        vim.keymap.set("n", "l", api.node.open.edit, opts())
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts())
      end
      require("nvim-tree").setup({
        on_attach = attach,
      })
    end,
  },

  ----------------------------
  -- terminal
  ----------------------------
  {
    "folke/snacks.nvim",
    lazy = false,
    opts = {
      terminal = {
        win = {
          position = "bottom", -- "bottom" | "top" | "left" | "right" | "float"
          height = 0.3,
        },
      },
    },

    keys = {
      {
        "<C-/>",
        mode = { "n", "t" },
        desc = "Toggle snacks terminal",
        silent = true,
        function()
          require("snacks.terminal").toggle()
        end,
      },
    },
  },

  ----------------------------
  -- file searching
  ----------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  ----------------------------
  -- outline(tagbar)
  ----------------------------
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = {
      { "<leader>t", "<cmd>SymbolsOutline<CR>", desc = "Toggle Symbols Outline" },
    },
    config = function()
      require("symbols-outline").setup({
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = "right",
        width = 20,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
      })
    end,
  },

  ----------------------------
  -- status line
  ----------------------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
      require("lualine").setup({
        options = { theme = require("lualine.themes.onedark") },
        sections = {
          lualine_x = {
            "filetype",
            "lua_progress",
            { lang_server_name },
          },
        },
      })
    end,
  },

  ----------------------------
  -- bufferline(buffer tabs)
  ----------------------------
  {
    "akinsho/bufferline.nvim",
    version = "*",
    lazy = false,
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = {
      { "H", "<Cmd>BufferLineCyclePrev<CR>", desc = "" },
      { "L", "<Cmd>BufferLineCycleNext<CR>", desc = "" },
    },
    config = function()
      require("bufferline").setup()
    end,
  },
}

-------------------------------------------------------------------------------
