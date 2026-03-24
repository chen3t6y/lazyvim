return {
  -- 1. 核心插件：LuaSnip 移植版
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    -- 确保在 LuaSnip 加载后再运行
    dependencies = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
    config = function()
      require("luasnip-latex-snippets").setup({
        use_treesitter = false, -- 建议设为 false，使用 vimtex 更加准确
        allow_on_markdown = true, -- 这里直接满足了你想在 md 中使用的需求
      })

      -- 必须开启自动扩展，否则 a1 不会自动变 a_1
      require("luasnip").config.setup({
        enable_autosnippets = true,
      })

      -- 2. 获取 LuaSnip 实例（这一步是必须的，否则无法调用 ls.snippet 等）
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node

      -- 获取插件自带的数学环境判定函数
      local is_math = function()
        return require("luasnip-latex-snippets.util.conditions").is_math()
      end

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
        s({ trig = "linen", name = "Line-Numbers" }, {
          i(1, "c"),
          t(" {.line-numbers}"),
          i(0),
        }),
      })
      -- aligned 环境
      -- ls.add_snippets("markdown", {
      --   s({ trig = "ali", snippetType = "autosnippet" }, {
      --     t({ "\\begin{aligned}", "\t" }),
      --     i(1),
      --     t({ "", "\\end{aligned}" }),
      --   }),
      -- })
      -- 自定义一个判定函数，直接调用 VimTeX
      -- 这样即便插件内部路径变了，你的判定依然有效
      local function is_math()
        -- 检查 VimTeX 的数学区判定
        return vim.fn["vimtex#syntax#in_mathzone"]() == 1
      end

      -- 强制将片段注入到 tex 和 markdown
      for _, ft in ipairs({ "tex", "markdown" }) do
        ls.add_snippets(ft, {
          -- ali -> aligned
          s({ trig = "ali", snippetType = "autosnippet" }, {
            t({ "\\begin{aligned}", "\t" }),
            i(1),
            t({ "", "\\end{aligned}" }),
          }, { condition = is_math }),

          -- beg -> 自动闭合环境
          s({ trig = "beg", snippetType = "autosnippet" }, {
            t("\\begin{"),
            i(1),
            t("}"),
            t({ "", "\t" }),
            i(0),
            t({ "", "\\end{" }),
            ls.function_node(function(args)
              return args[1][1]
            end, { 1 }),
            t("}"),
          }, { condition = is_math }),
        }, { type = "autosnippets" })
      end
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
