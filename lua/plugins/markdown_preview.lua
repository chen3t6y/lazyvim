return {
  {
    "iamcco/markdown-preview.nvim",
    lazy = false,
    -- 强制启用 node 支持
    init = function()
      vim.g.loaded_node_provider = nil -- 移除禁用标志
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
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
