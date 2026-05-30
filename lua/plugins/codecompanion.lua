return {
  "olimorris/codecompanion.nvim",
  version = "^19.0.0",
  lazy = false,
  keys = {
    { "<C-a>", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI 动作面板" },
    { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "切换 AI 聊天" },
    { "<leader>ae", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "AI 行内智能修改" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "codecompanion" },
      opts = { file_types = { "markdown", "codecompanion" } },
    },
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = { insert_mode = true },
          use_absolute_path = true,
        },
      },
    },
  },
  config = function()
    require("codecompanion").setup({
      -- 1. 核心交互策略：直接指向官方池子里绝对存在的 "deepseek"
      strategies = {
        chat = {
          adapter = "deepseek",
          -- adapter = "gemini",
          opts = {
            -- 强制侧边栏聊天必须使用中文回复
            -- system_prompt = "You are a helpful AI assistant. You must always reply to the user in Chinese (中文), especially when explaining code.",
          },
        },
        inline = {
          adapter = "deepseek",
          -- adapter = "gemini",
          -- 行内代码修改保持默认，因为写代码注释或代码本身通常不需要被强制中文干扰

          -- 这里是关键：改变它的展示布局
          layout = "vertical", -- 可选值: "vertical" (垂直分屏), "horizontal" (水平分屏)
        },
      },

      -- 2. 直接对官方原生的 "deepseek" 适配器进行重置与拦截
      adapters = {
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              -- 完美读取你的本地环境变量（请确保在 Fish/Bash 中 export 了该变量）
              api_key = "GEMINI_API_KEY",
            },
            schema = {
              model = {
                -- 强行覆盖官方旧默认模型，进入 3.5 时代
                default = "gemini-3.5-flash",
              },
            },
          })
        end,
        deepseek = function()
          return require("codecompanion.adapters").extend("deepseek", {
            env = {
              api_key = "DEEPSEEK_API_KEY", -- 读取你的 fish 环境变量
            },
            schema = {
              model = {
                default = "deepseek-v4-flash", -- 暴力覆盖官方老旧的默认模型，强制进入 2026 年 V4 时代
              },
            },
          })
        end,
      },

      display = {
        action_palette = { provider = "telescope" },
        chat = {
          show_token_count = true,
          window = { layout = "vertical", width = 0.35 },
        },
        diff = {
          provider = "default", -- 或 "default" (Neovim 自带 diff)
        },
      },
      opts = {
        log_level = "ERROR",
        send_code = true,
        language = "Chinese",
      },
    })

    -- 留存的可视模式快捷键与命令行简写
    vim.keymap.set(
      "v",
      "ga",
      "<cmd>CodeCompanionChat Add<cr>",
      { noremap = true, silent = true, desc = "将选中代码送入 AI 聊天" }
    )
    vim.cmd([[cab aa CodeCompanion]])
  end,
}
