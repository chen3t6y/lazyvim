return {
  -- Godot filetype highlight support
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "gdscript", "godot_resource", "gdshader" })
    end,
  },
  -- Godot integration: LSP + DAP + run commands
  {
    "lommix/godot.nvim",
    dependencies = {
      "mfussenegger/nvim-dap",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    lazy = true,
    ft = { "gdscript", "gd", "gdshader" },
    cmd = {
      "GodotDebug",
      "GodotBreakAtCursor",
      "GodotStep",
      "GodotContinue",
      "GodotQuit",
    },
    config = function()
      -- NOTE: requiring the module runs its built-in auto-setup immediately
      -- (creates the commands with default config). A second setup() with our
      -- opts would hit "Command already exists", so remove the auto-created
      -- commands first, then re-run setup with our options.
      require("godot")
      pcall(vim.api.nvim_del_user_command, "GodotDebug")
      pcall(vim.api.nvim_del_user_command, "GodotBreakAtCursor")
      pcall(vim.api.nvim_del_user_command, "GodotStep")
      pcall(vim.api.nvim_del_user_command, "GodotContinue")
      pcall(vim.api.nvim_del_user_command, "GodotQuit")

      require("godot").setup({
        bin = "godot",
        dap = {
          host = "127.0.0.1",
          port = 6006, -- Godot DAP port (editor: Network -> Debug Adapter)
        },
        expose_commands = true,
        -- lspconfig has no 0.11+ style gdscript config, so wire the official
        -- Godot LSP port (6005) manually, otherwise no client is registered.
        lsp_opts = {
          cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
          filetypes = { "gd", "gdscript", "gdscript3" },
        },
      })

      -- Godot 4.6+ ignores the plugin's default `launch_scene = true`;
      -- use the native `scene` field so :GodotDebug targets the scene
      -- currently open in the editor.
      local dap = require("dap")
      dap.configurations.gdscript = {
        {
          type = "godot",
          request = "launch",
          name = "Launch current scene",
          project = "${workspaceFolder}",
          scene = "current",
        },
      }
    end,
  },
}