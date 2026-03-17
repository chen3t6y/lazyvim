return {
  "lervag/vimtex",
  lazy = false, -- VimTeX 建议不要延迟加载
  init = function()
    -- 在这里进行 VimTeX 的相关设置
    vim.g.vimtex_view_method = "zathura" -- 根据你的操作系统修改阅读器
  end,
}
