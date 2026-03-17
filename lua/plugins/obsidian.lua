return {
  -- 1. 配置 obsidian.nvim
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      -- 即使不启用 nvim-cmp，代码逻辑仍需引用其模块
      "hrsh7th/nvim-cmp",
    },
    keys = {
      -- 搜索与导航
      { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search Obsidian Notes" },
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian Note" },
      { "<leader>oo", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick Switch (Picker)" },
      -- 日记功能
      { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Today's Daily Note" },
      { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Yesterday's Daily Note" },
      -- 模板与链接
      { "<leader>ot", "<cmd>ObsidianTemplate<cr>", desc = "Insert Template" },
      { "<leader>ol", "<cmd>ObsidianLink<cr>", desc = "Link Visual Selection", mode = "v" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show Backlinks" },
    },
    opts = {
      workspaces = {
        {
          name = "chen_note",
          path = "~/chen_note",
        },
      },
      notes_subdir = "00_Inbox",
      log_level = vim.log.levels.INFO,
      daily_notes = {
        folder = "04_Daily",
        date_format = "%Y-%m-%d",
        template = "Templates/Daily_Template.md",
      },
      completion = {
        -- 必须设为 false，防止插件自动去找不存在的 nvim-cmp
        nvim_cmp = false,
        min_chars = 2,
      },
      templates = {
        subdir = "Templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },
      attachments = {
        img_folder = "assets",
      },
      ui = {
        enable = true,
        update_debounce = 200,
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
        },
      },
    },
    config = function(_, opts)
      require("obsidian").setup(opts)

      -- 核心 HACK：手动向已加载的 cmp 模块注册 obsidian 源
      -- 这步是为了让 blink.compat 能够通过 require("cmp") 找到并桥接这些源
      local status, cmp = pcall(require, "cmp")
      if status then
        cmp.register_source("obsidian", require("cmp_obsidian").new())
        cmp.register_source("obsidian_new", require("cmp_obsidian_new").new())
        cmp.register_source("obsidian_tags", require("cmp_obsidian_tags").new())
      end

      -- 命令行补全优化
      vim.opt.wildmode = "longest:full,full"
      vim.opt.wildoptions = "pum"
    end,
  },

  -- 2. 配置 blink.cmp 及其兼容层
  {
    "saghen/blink.cmp",
    dependencies = {
      { "saghen/blink.compat", opts = {} }, -- 必须启用兼容层
    },
    opts = {
      sources = {
        -- 将 obsidian 系列源加入默认补全列表
        default = { "lsp", "path", "snippets", "buffer", "obsidian", "obsidian_new", "obsidian_tags" },
        providers = {
          -- 告诉 blink 使用 compat 模块来调用之前手动注册的源
          obsidian = {
            name = "obsidian",
            module = "blink.compat.source",
          },
          obsidian_new = {
            name = "obsidian_new",
            module = "blink.compat.source",
          },
          obsidian_tags = {
            name = "obsidian_tags",
            module = "blink.compat.source",
          },
        },
      },
    },
  },
}
