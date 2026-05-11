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

      -- Restore the default input method state when the following events are triggered
      -- "VimEnter" and "FocusGained" were removed for causing problems, add it by your needs
      -- set_default_events = { "InsertLeave", "CmdlineLeave" },
      set_default_events = { "InsertLeave" },

      -- Restore the previous used input method state when the following events
      -- are triggered, if you don't want to restore previous used im in Insert mode,
      -- e.g. deprecated `disable_auto_restore = 1`, just let it empty
      -- as `set_previous_events = {}`
      set_previous_events = { "InsertEnter" },

      -- Show notification about how to install executable binary when binary missed
      keep_quiet_on_no_binary = false,

      -- 开启异步切换，防止输入法切换时导致 Neovim 卡顿
      async_switch_im = true,
    })
  end,
}
