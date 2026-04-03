return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- 禁用自带的拼写检查
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text" },
        callback = function()
          vim.opt_local.spell = false -- 禁用 Neovim 内置 spell
          vim.opt_local.conceallevel = 2 -- 顺便保持 md 的显示效果
        end,
      })
    end,
  },
}
