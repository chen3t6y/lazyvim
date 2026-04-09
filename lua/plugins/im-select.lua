return {
  "keaising/im-select.nvim",
  event = { "InsertEnter", "FocusGained" }, -- 懒加载：进入插入模式或重获焦点时启动
  config = function()
    require("im_select").setup({
      -- Fcitx5 的默认英文状态名称通常是 keyboard-us
      -- 如果你的不一样，可以通过在终端输入 `fcitx5-remote -n` 查看
      default_im_select = "keyboard-us",

      -- 指定使用 fcitx5-remote
      default_command = "fcitx5-remote",

      -- 开启异步切换，防止输入法切换时导致 Neovim 卡顿
      async_switch_im = true,
    })
  end,
}
