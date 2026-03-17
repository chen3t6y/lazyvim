return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    default = {
      prompt_for_file_name = false,
      dir_path = function()
        local filename = vim.fn.expand("%:t:r")
        if filename == "" then
          filename = "untitled"
        end
        return "Image/" .. filename
      end,

      -- 修改这里：使用 os.date 生成可阅读时间
      -- %Y-%m-%d-%H-%M-%S 分别代表 年-月-日-时-分-秒
      file_name = function()
        return "image-" .. os.date("%Y-%m-%d-%H-%M-%S")
      end,

      use_absolute_path = false,
      template = "![]($FILE_PATH)",
    },
  },
  keys = {
    { "<leader>pi", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
  },
}
