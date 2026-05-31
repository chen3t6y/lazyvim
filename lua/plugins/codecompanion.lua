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
            -- system_prompt = "你正在严格遵循 GitHub Spec Kit 的 Spec-Driven Development 流程。请始终参考 .specify/ 目录下的 constitution、templates 和 workflows。",
          },
        },
        inline = {
          adapter = "deepseek",
          -- adapter = "gemini",
          -- 行内代码修改保持默认，因为写代码注释或代码本身通常不需要被强制中文干扰

          -- 这里是关键：改变它的展示布局
          -- layout = "vertical", -- 可选值: "vertical" (垂直分屏), "horizontal" (水平分屏)
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

      prompt_library = {
        markdown = {
          dirs = {
            vim.fn.stdpath("config") .. "/prompts", -- 全局 prompts
            vim.fn.getcwd() .. "/.specify/templates", -- Spec Kit 模板
          },
        },
      },

      rules = {
        dirs = {
          vim.fn.getcwd() .. "/.specify", -- 让 CodeCompanion 自动读取 .specify 内容
        },
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

-- # 安装
-- uvx --from git+https://github.com/github/spec-kit.git specify init . --integration generic --integration-options="--commands-dir .github/commands"
-- # 项目目录下的 AGENTS.md
-- # AGENTS.md - Spec Kit 指令集
--
-- 你正在使用 **GitHub Spec Kit** 进行 **Spec-Driven Development（规格驱动开发）**。
--
-- ## 核心目录结构参考
-- - `.specify/memory/constitution.md` → 项目宪法（最高优先级）
-- - `.specify/templates/` → 各种模板（spec、plan、tasks、checklist）
-- - `.specify/workflows/` → 工作流定义
-- - `.specify/extensions/` → git、agent-context 等扩展
--
-- ## 推荐工作流（严格遵守）
-- 1. **Constitution** → 先阅读或建立项目原则
-- 2. **Specify** → 从需求生成规格文档
-- 3. **Clarify**（可选）→ 澄清模糊点
-- 4. **Plan** → 生成技术计划
-- 5. **Tasks** → 生成可执行任务列表
-- 6. **Implement** → 编码实现
-- 7. **Validate / Checklist** → 检查一致性
--
-- ## 可用指令（你可以直接说或用 / 开头）
-- - `/speckit.constitution` → 初始化或更新宪法
-- - `/speckit.specify <需求>` → 生成规格文档
-- - `/speckit.plan` → 生成实现计划
-- - `/speckit.tasks` → 生成任务清单
-- - `/speckit.analyze` → 一致性分析
-- - `/speckit.implement` → 开始实现
-- - `/speckit.checklist` → 生成检查清单
--
-- **请始终先读取 `.specify/memory/constitution.md`，然后严格按 Spec Kit 模板和流程回复。**
--
-- # 输入对话(两个都要)
--             -- system_prompt = "你正在严格遵循 GitHub Spec Kit 的 Spec-Driven Development 流程。请始终参考 .specify/ 目录下的 constitution、templates 和 workflows。",
-- # 输入对话
-- 你现在是 Spec Kit Agent。请先读取 AGENTS.md 和 .specify/memory/constitution.md，然后严格按照 Spec-Driven Development 流程工作。当前任务：
--
-- 使用方法
--
-- 太棒了！你的 Neovim 已经完成了最硬核的底层改造，现在它不仅是一个编辑器，更是一个高度规范的**工业级软件工程流水线**。
--
-- 为了让你在日常编码中用得行云流水，下面为你梳理一套完整的**日常使用流程**，以及那些 `/` 命令在实际开发中到底该怎么配合使用。
--
-- ---
--
-- ## 🛠️ 第一部分：核心 `/` 命令深度拆解
--
-- 在你的新配置下，在 Chat 窗口（`<leader>aa`）中敲下 `/` 时，这些命令的底层逻辑和产出目标如下：
--
-- | 命令 | 什么时候用？ | 它的核心作用（AI 怎么做） | 最终你得到的产出物 |
-- | --- | --- | --- | --- |
-- | **`/speckit.constitution`** | 项目刚立项或引入新规范时 | 确立项目的“最高宪法”，包括技术栈选型、代码洁癖、性能红线、命名规范等。 | 生成或更新 `.specify/memory/constitution.md` |
-- | **`/speckit.specify`** | **【阶段 1】** 听到口头需求时 | 将你极其模糊的大白话需求，翻译成逻辑严密、包含边界条件、无歧义的功能规格说明书（强制使用 **EARS 语法**）。 | 生成 `.sdd/spec.md` (或 `spec-template.md` 格式文件) |
-- | **`/speckit.clarify`** | **【插曲】** 规划前发现需求有漏洞 | AI 会主动列出需求中的灰色地带和逻辑死角（比如：网络断开时怎么处理？Token 过期怎么办？），让你做单选题或填空题。 | 消除设计前的风险隐患 |
-- | **`/speckit.plan`** | **【阶段 2】** 需求规格敲定后 | 分析你现有的代码库（静态拓扑），根据规格书设计系统架构、模块接口、数据流向。**此时严禁写具体的业务代码！** | 生成 `.sdd/plan.md` |
-- | **`/speckit.tasks`** | **【阶段 3】** 架构图纸画好后 | 把宏观的架构拆解成可以分配给低级程序员（或执行 AI）干活的、有依赖关系的 **Markdown 任务清单（Todo List）**。 | 生成 `.sdd/tasks.md` |
-- | **`/speckit.analyze`** | **【质量关卡】** 动手前或动手后 | 交叉检查：需求文档、架构计划和任务清单之间是否完全对齐。防止写着写着歪楼。 | 一致性审查报告 |
-- | **`/speckit.implement`** | **【阶段 4】** 正式动手写代码 | 严格对照任务清单的某一项，读取规格书和宪法，开始在你的源文件（如 `main.c`）里编写高鲁棒性的业务代码。 | 真正改变你代码库的源文件 |
-- | **`/speckit.checklist`** | **【阶段 5】** 交付前的最后一关 | 针对刚才生成的代码，自动产出质量验收清单（如内存泄漏检查、边界溢出测试、异常捕获等），用来做最后的 Code Review。 | 验收清单与测试指导 |
--
-- ---
--
-- ## 🔄 第二部分：标准 SDD（规格驱动开发）实战流水线
--
-- 假设你现在要写一个新功能：**“在你的 C 语言学生管理系统里，增加一个通过学号查找学生，并支持导出为 CSV 的功能”**。你在 Neovim 里应该这样优雅地推进：
--
-- ### 1. 唤醒 Agent 与阅读宪法
--
-- 在项目根目录下用 Neovim 打开任意文件，按下 `<leader>aa` 调出侧边栏 Chat。
-- 输入首发指令，让 AI 进入状态：
--
-- ```text
-- 你现在是 Spec Kit Agent。请先读取 AGENTS.md 和 .specify/memory/constitution.md。接下来的每一步，都必须严格遵守 SDD 流程。
--
-- ```
--
-- ### 2. 需求定稿阶段（Specify）
--
-- 你不需要一上来就写 `FILE *fp = fopen(...)`。在聊天框里直接调用命令：
--
-- ```text
-- /speckit.specify 用户想要一个通过学号（ID）查找学生的功能，查到后可以点击导出为 CSV 文件。如果学号不存在，要给出友好的报错提示。
--
-- ```
--
-- * **AI 的反应**：DeepSeek 会根据 `.specify/templates/spec-template.md` 的格式，为你疯狂输出一份极其严谨的需求规格文档。
-- * **你的动作**：在项目根目录下新建一个 `.sdd/` 文件夹（用来存放图纸）。把 AI 吐出来的这段 Markdown 复制保存为 `.sdd/spec.md`。
--
-- ### 3. 架构设计阶段（Plan & Tasks）
--
-- 规格书存好后，在聊天框里继续：
--
-- ```text
-- @file:.sdd/spec.md
-- 很好，规格书已定稿。请执行 /speckit.plan 分析现有项目结构，给出最稳健的架构设计。
--
-- ```
--
-- * **AI 的反应**：它会告诉你需要修改哪个头文件（`.h`），需要新增哪个结构体，以及怎么设计导出 CSV 的函数接口。
-- * **你的动作**：将设计文档保存为 `.sdd/plan.md`。
-- * **接着拆任务**：在聊天框输入 `/speckit.tasks`。AI 会给你吐出一个任务列表（Task 1: 定义接口；Task 2: 实现搜索；Task 3: 实现 CSV 写入...）。你将其保存为 `.sdd/tasks.md`。
--
-- ### 4. 无情干活阶段（Implement）
--
-- 现在设计图纸全在 `.sdd/` 里了。重新开一个干净的 Chat，或者直接在空的 `student_export.c` 缓冲区中按下 `<leader>ae`（Inline 行内智能修改模式），输入：
--
-- ```text
-- @file:.sdd/spec.md @file:.sdd/plan.md @file:.sdd/tasks.md
-- 请严格依照这些设计规范，在此文件中实现 Task 1 和 Task 2：编写通过学号查找学生并生成 CSV 字符串的核心函数。
--
-- ```
--
-- * **核心优势**：此时写出来的代码，由于头顶悬着 `.specify` 宪法和 `.sdd` 规范，大模型绝对不会瞎写、乱起名字或者漏掉边界检查。它交付的代码质量会极高。
--
-- ### 5. 质量验收（Checklist）
--
-- 代码生成在缓冲区后，选中它，按下 `ga`（将选中代码送入 AI 聊天），然后在 Chat 框里输入：
--
-- ```text
-- /speckit.checklist 检查刚才生成的这段代码，重点帮我看看有没有指针未初始化、内存泄漏或者未关闭文件流的风险。
--
-- ```
--
-- 根据 AI 给出的 Checklist 调整代码，收工，提交 Git！
--
-- ---
--
-- ## 💡 终极极客心智：为什么我们要这么折腾？
--
-- 普通的 AI 辅助是“氛围感盲盒编程（Vibe Coding）”——你爽快地下令，它爽快地吐出 200 行代码，你直接粘贴，然后发现编译报错，你再把报错喂给它，它再改，陷入无尽的“修 Bug 循环”。
--
-- 而你现在这套 **CodeCompanion + Spec Kit** 的组合拳，是在**用写文档的时间来换取代码一次性编译通过的概率**。当你在前 3 个阶段把需求、架构、任务卡死在 Markdown 文件里时，最后的 `Implement` 阶段对 AI 来说只是闭着眼睛填空而已，极其舒适、极度严谨。
