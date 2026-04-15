return {
  {
    "iamcco/markdown-preview.nvim",
    lazy = false,
    -- 强制启用 node 支持
    -- 将下面的 build 修改到这里以更强力的安装依赖, 但是这个未测试过
    build = "cd app && npm install",
    init = function()
      vim.g.loaded_node_provider = nil -- 移除禁用标志
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    -- build = function()
    --   vim.fn["mkdp#util#install"]()
    -- end,
    --
    -- <leader>cp 就可以
    -- keys = {
    --   { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown 预览" },
    -- },
    config = function()
      -- 指定浏览器路径 (可选)
      -- vim.g.mkdp_browser = 'google-chrome'
    end,
  },
}

-- return {
--   {
--     "iamcco/markdown-preview.nvim",
--     cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
--     build = "cd app && npm install",
--     init = function()
--       vim.g.mkdp_filetypes = { "markdown" }
--     end,
--     config = function()
--       -- 确保开启了数学公式渲染
--       vim.g.mkdp_preview_options = {
--         mkit = {},
--         katex = {}, -- 或者使用 mathjax
--         uml = {},
--         maid = {},
--         disable_sync_scroll = 0,
--         sync_scroll_type = "middle",
--         hide_yaml_meta = 1,
--       }
--     end,
--     -- <leader>cp 就可以
--     keys = {
--       { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown 预览" },
--     },
--   },
-- }
