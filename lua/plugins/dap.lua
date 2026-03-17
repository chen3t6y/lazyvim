return {
  "mfussenegger/nvim-dap",
  opts = function()
    local dap = require("dap")

    dap.configurations.c = {
      {
        name = "C: Auto Build & Debug",
        type = "codelldb", -- 确保 Mason 里安装了 codelldb
        request = "launch",
        program = function()
          -- 1. 变量定义
          local file_path = vim.fn.expand("%:p") -- 当前文件绝对路径
          local binary_path = vim.fn.expand("%:p:r") -- 编译后的可执行文件路径

          -- 2. 执行编译命令
          -- 使用 g++ 或 gcc，-g 是调试必需的
          local compile_cmd = string.format("gcc -g '%s' -o '%s'", file_path, binary_path)

          print("Compiling...")
          local output = vim.fn.system(compile_cmd)

          -- 3. 检查编译是否成功
          if vim.v.shell_error ~= 0 then
            vim.notify("Compilation Failed:\n" .. output, vim.log.levels.ERROR)
            return dap.ABORT -- 终止调试启动
          end

          -- 4. 编译成功，返回二进制文件路径启动调试
          return binary_path
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }

    -- 5. 自动清理逻辑：监听调试退出事件
    local function cleanup()
      local binary_path = vim.fn.expand("%:p:r")
      if vim.fn.filereadable(binary_path) == 1 then
        os.remove(binary_path)
        print("Binary cleaned up.")
      end
    end

    -- 无论调试是正常结束还是被强行停止，都执行清理
    dap.listeners.after.event_terminated["dap_cleanup"] = cleanup
    dap.listeners.after.event_exited["dap_cleanup"] = cleanup
  end,
}
