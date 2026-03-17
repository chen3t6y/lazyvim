return {
  "jalvesaq/zotcite",
  dependencies = { "nvim-treesitter/nvim-treesitter" }, -- 必须（YAML 解析）
  -- 可选：加 telescope 更炫
  -- dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-telescope/telescope.nvim" },
  config = function()
    require("zotcite").setup({
      -- 这里可以自定义，比如改 citation 格式（默认就是 Pandoc 风格）
      -- 详见 :help zotcite
    })
  end,
}
