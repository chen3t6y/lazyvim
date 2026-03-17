return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile", -- 只有打开文件时才加载，节省内存
    enabled = true, -- 确保它是开启状态
    opts = {
      mode = "cursor", -- 粘性行跟随光标
      max_lines = 3, -- 最多显示几行（防止太占地方，建议 3-5 行）
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20, -- 多行函数头显示阈值
      trim_scope = "outer", -- 超过限制时，去掉外层还是内层
    },
    keys = {
      -- 快捷键：跳转到顶部的粘性上下文（非常有用的功能！）
      {
        "[c",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        desc = "跳转到上层上下文 (Go to context)",
      },
    },
  },
}
