-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- xingchen
-- 1. Zotero 引用插入（带反馈提示）
vim.keymap.set("i", "<C-z>", function()
  local api_url = "http://localhost:23119/better-bibtex/cayw?format=pandoc"
  local cmd = "curl -s " .. vim.fn.shellescape(api_url)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()

  if result ~= "" then
    vim.api.nvim_put({ result }, "c", false, true)
    vim.notify("Citation inserted: " .. result, vim.log.levels.INFO, { title = "Zotero" })
  else
    vim.notify("No citation selected!", vim.log.levels.ERROR, { title = "Zotero" })
  end
end, { desc = "Zotero Search & Insert" })

-- 2. 任务管理快捷键
vim.keymap.set("n", "<leader>rp", "<cmd>OverseerRun Academic Compile (PDF)<cr>", { desc = "Compile PDF" })
vim.keymap.set("n", "<leader>rt", "<cmd>OverseerToggle<cr>", { desc = "Task List" })
