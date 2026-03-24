return {
  "kawre/leetcode.nvim",
  build = ":TSUpdate html", -- 增强题目描述的渲染
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim", -- 必选依赖
    "MunifTanjim/nui.nvim", -- 界面组件
    "nvim-treesitter/nvim-treesitter",
    "rcarriga/nvim-notify", -- 可选，用于漂亮的通知
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- 在这里配置你的偏好
    lang = "c", -- 设置你常用的编程语言
    cn = { enabled = true },
    storage = {
      home = vim.fn.stdpath("data") .. "/leetcode", -- 题目保存路径
    },
  },
}
