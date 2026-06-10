return {
  -- 1. 核心插件：LuaSnip 移植版
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    -- 确保在 LuaSnip 加载后再运行
    dependencies = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
    config = function()
      require("luasnip-latex-snippets").setup({
        use_treesitter = true, -- 使用 treesitter 检测数学模式，避免 vimtex 解析延迟问题
        allow_on_markdown = true, -- 这里直接满足了你想在 md 中使用的需求
      })

      -- 必须开启自动扩展，否则 a1 不会自动变 a_1
      require("luasnip").config.setup({
        enable_autosnippets = true,
      })

      -- 2. 获取 LuaSnip 实例（这一步是必须的，否则无法调用 ls.snippet 等）
      local ls = require("luasnip")
      -- local utils = require("luasnip-latex-snippets.util.utils")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      -- local f = ls.function_node

      -- 获取插件自带的数学环境判定函数
      -- local is_math = function()
      --   return require("luasnip-latex-snippets.util.conditions").is_math()
      -- end

      -- 3. 添加你的自定义 Snippets
      -- 你可以把这段代码复制到这里
      -- ls.add_snippets("tex", {
      --   s("note", {
      --     t("% TODO: "), i(1), t(" (Created: "), t(os.date("%Y-%m-%d")), t(")")
      --   }),
      -- })

      -- -- 如果你想在 Markdown 中也生效，可以再加一行映射
      -- ls.add_snippets("markdown", {
      --   s("note", {
      --     t("")
      --   }),
      -- })

      -- 在 ``` 代码块中添加语言和行号
      ls.add_snippets("markdown", {
        s({ trig = "```ln", name = "Line-Numbers" }, {
          t("```"),
          i(1, "c"),
          t(" {.line-numbers}"),
          i(0),
        }),
      })

      -- bwA snippets for markdown (plugin filters these out, replaced with is_math condition)
      local utils = require("luasnip-latex-snippets.util.utils")
      local pipe = utils.pipe
      local conds = require("luasnip.extras.expand_conditions")
      local is_math = utils.with_opts(utils.is_math, true)
      local condition = pipe({ conds.line_begin, is_math })

      local bwA_s = ls.extend_decorator.apply(ls.snippet, { condition = condition })
      local bwA_ps = ls.extend_decorator.apply(ls.parser.parse_snippet, { condition = condition })

      ls.add_snippets("markdown", {
        bwA_s(
          { trig = "ali", name = "Align" },
          { t({ "\\begin{align*}", "\t" }), i(1), t({ "", "\\end{align*}" }) }
        ),
        bwA_ps({ trig = "beg", name = "begin{} / end{}" }, "\\begin{$1}\n\t$0\n\\end{$1}"),
        bwA_s(
          { trig = "bigfun", name = "Big function" },
          { t({ "\\begin{align*}", "\t" }), i(1), t(":"), t(" "), i(2),
            t("&\\longrightarrow "), i(3), t({ " \\", "\t" }), i(4),
            t("&\\longmapsto "), i(1), t("("), i(4), t(")"), t(" = "),
            i(0), t({ "", "\\end{align*}" }) }
        ),
      }, { default_priority = 0 })

      -- Prevent mk from expanding inside fenced code blocks in markdown
      -- (plugin's mk has condition=not_math which is true in code blocks)
      local function in_code_block()
        local node = vim.treesitter.get_node({ ignore_injections = false })
        if not node then return false end
        while node do
          local nt = node:type()
          if nt == "fenced_code_block" or nt == "indented_code_block" then
            return true
          end
          node = node:parent()
        end
        return false
      end

      local not_math = utils.with_opts(utils.not_math, true)
      local not_in_code = function() return not in_code_block() end
      local code_cond = function() return in_code_block() end

      local mk_ok_s = ls.extend_decorator.apply(ls.snippet, {
        condition = pipe({ not_math, not_in_code }),
      })
      local mk_code_s = ls.extend_decorator.apply(ls.snippet, {
        condition = pipe({ not_math, code_cond }),
      })

      ls.add_snippets("markdown", {
        mk_ok_s(
          { trig = "mk", name = "Math" },
          { t("$"), i(1), t("$"), i(0) }
        ),
        -- Catch-all inside code blocks: expand to literal "mk" (no-op,
        -- prevents plugin's mk from firing)
        mk_code_s(
          { trig = "mk", name = "Math (code block)" },
          { t("mk") }
        ),
      }, { type = "autosnippets", default_priority = 1000 })

      -- 强制将片段注入到 tex 和 markdown (old, replaced by bwA above)
      -- for _, ft in ipairs({ "markdown" }) do
      --   ls.add_snippets(ft, {
      --     -- ali -> aligned
      --     s({ trig = "ali" }, {
      --       t({ "\\begin{aligned}", "\t" }),
      --       i(1),
      --       t({ "", "\\end{aligned}" }),
      --     }),
      --
      --     -- beg -> 自动闭合环境
      --     s({ trig = "beg" }, {
      --       t("\\begin{"),
      --       i(1),
      --       t("}"),
      --       t({ "", "\t" }),
      --       i(0),
      --       t({ "", "\\end{" }),
      --       ls.function_node(function(args)
      --         return args[1][1]
      --       end, { 1 }),
      --       t("}"),
      --     }),
      --   })
      -- end
    end,
  },

  -- 2. 配置 VimTeX (提供数学环境检测)
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_quickfix_mode = 0
    end,
  },
}
