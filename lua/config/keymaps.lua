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

-- 调试
-- ~/.config/nvim/lua/config/keymaps.lua

local dap = require("dap")

-- 绑定 Step Into (di) 到 F11
vim.keymap.set("n", "<F9>", function()
  dap.step_into()
end, { desc = "Debugger: Step Into" })

-- 绑定 Step Over (dO) 到 F10
vim.keymap.set("n", "<F10>", function()
  dap.step_over()
end, { desc = "Debugger: Step Over" })

-- 绑定 Step Out (do) 到 F12
vim.keymap.set("n", "<S-F9>", function()
  dap.step_out()
end, { desc = "Debugger: Step Out" })

-- 额外建议：把“继续/开始”绑到 F5，体验更完整
vim.keymap.set("n", "<F5>", function()
  dap.continue()
end, { desc = "Debugger: Continue" })
