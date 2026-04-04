return {
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      -- WezTerm 建议先试 sixel，如果显示有问题再切 kitty
      backend = "sixel",
      -- 既然系统装了 magick 模块，直接用 magick_rock 性能更好
      processor = "magick_rock",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" },
        },
      },
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = 50,
      -- 当有窗口重叠时，自动清除图片以防止乱码
      window_overlap_clear_enabled = false,
      -- 忽略某些不会引发冲突的浮窗（如通知）
      -- window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif" },
      pipe_path = "/tmp/nvim-image-nvim",
    },
  },
}
