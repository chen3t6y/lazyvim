return {
  "mfussenegger/nvim-dap",
  opts = function()
    local dap = require("dap")

    dap.configurations.c = {
      {
        name = "C: Build All *.c & Debug",
        type = "codelldb",
        request = "launch",
        program = function()
          -- 1. 定义变量
          -- 获取当前文件所在目录或工作区目录
          local cwd = vim.fn.getcwd()
          -- 定义编译后的二进制文件名，例如叫 'main_executable'
          local binary_path = cwd .. "/debug_bin.exe"

          -- 2. 执行编译命令
          -- 使用 *.c 匹配当前目录下所有 C 文件
          -- 注意：如果文件较多，建议使用 Makefile，此处为简单实现
          local compile_cmd = string.format("gcc -g %s/*.c -o '%s' -lm", cwd, binary_path)

          print("Compiling all .c files in " .. cwd .. " ...")
          local output = vim.fn.system(compile_cmd)

          -- 3. 检查编译是否成功
          if vim.v.shell_error ~= 0 then
            vim.notify("Compilation Failed:\n" .. output, vim.log.levels.ERROR)
            return nil -- nvim-dap 中返回 nil 或 dap.ABORT 均可终止
          end

          -- 4. 返回二进制文件路径
          return binary_path
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {}, -- 如果程序需要运行时参数，在此添加
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
