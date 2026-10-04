return {
  {
    "sudo-tee/opencode.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          anti_conceal = { enabled = false },
          file_types = { "markdown", "opencode_output" },
        },
        ft = { "markdown", "copilot-chat", "opencode_output" },
      },
    },
    config = function()
      require("opencode").setup({
        -- 默认用 omo 的 orchestrator 模式而不是 build
        default_mode = "orchestrator",
        -- 键位从 <leader>o 挪到 <leader>a,把 o 前缀让给 obsidian.nvim
        keymap_prefix = "<leader>a",
        -- 已安装 blink.cmp,用于输入窗口的 @文件/命令 补全
        preferred_completion = "blink",
        -- 已安装 snacks.nvim,用作文件提及选择器
        preferred_picker = "snacks",
      })
    end,
  },
}