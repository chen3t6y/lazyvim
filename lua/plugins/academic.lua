return {
  -- 建议安装这个插件，它能让你在 Markdown 中获得类似 IDE 的体验
  {
    "jmbuhr/otter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("otter").setup({})
    end,
  },
}
