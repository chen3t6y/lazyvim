-- ---------------------------------------------------------------------------
-- 日记自动打标签:把"改动过的标题"的文字部分加入 frontmatter tags
-- (仅对 04_Daily 下的笔记生效;通过 note_frontmatter_func 挂在插件每次保存时)
-- ---------------------------------------------------------------------------

--- 规范化标题文字:去掉前导 #、emoji/符号、首尾空白,ASCII 转小写
--- 例: "## 🎵 音乐" -> "音乐"、"## 🔠 English" -> "english"、"### 箫" -> "箫"
--- 注:Lua 模式是字节级,emoji 续字节(0x80-0xBF)与中文无法用 [一-龥] 区分。
--- emoji/符号前导字节为 0xE2-0xE3(3字节符号)或 0xF0-0xF3(4字节 emoji),
--- 而 CJK 前导字节为 0xE4-0xE9,刻意排除,避免把汉字当符号剥掉。
local SYMBOL_LEAD = "[\226-\227\240-\243]" -- E2-E3 ∪ F0-F3
local function normalize_heading(text)
  text = text:gsub("^#+%s*", "")
  text = text:gsub("%s+$", "")
  -- 去掉前导的 emoji/符号(多字节字符),含 🇬🇧 国旗这类两个字符的组合
  for _ = 1, 8 do
    local before = text
    text = text:gsub("^" .. SYMBOL_LEAD .. "[\128-\191]*%s*", "")
    if text == before then
      break
    end
  end
  -- 去掉剩余的 ASCII 标点/空白前缀(如 "## - 任务")
  text = text:gsub("^[%p%s]+", "")
  -- 去掉尾部的 ASCII 标点与多字节符号
  text = text:gsub("[%p%s]+$", "")
  for _ = 1, 8 do
    local before = text
    text = text:gsub(SYMBOL_LEAD .. "[\128-\191]*$", "")
    if text == before then
      break
    end
  end
  return text:lower()
end

--- 规范化内容行:去首尾空白(用于内容对比)
local function norm_content(line)
  return (line:gsub("^%s+", ""):gsub("%s+$", ""))
end

--- 读取日记模板(相对 vault 根目录 Templates/Daily_Template.md):
--- 返回 { 规范化标题文字 -> { 规范化内容行列表 } } 作为基线
local function template_section_map(note)
  local daily_dir = vim.fs.dirname(tostring(note.path))
  local vault_root = vim.fs.dirname(daily_dir)
  local tmpl_path = vim.fs.joinpath(vault_root, "Templates", "Daily_Template.md")

  local map = {}
  local f = io.open(tmpl_path, "r")
  if f == nil then
    return map
  end
  local cur_key = nil
  local in_code = false
  for line in f:lines() do
    if line:match("^```") or line:match("^~~~") then
      in_code = not in_code
    elseif not in_code then
      local lvl = line:match("^(#+)")
      if lvl ~= nil and #lvl >= 2 then
        local text = normalize_heading(line)
        if text ~= "" then
          cur_key = text
          map[cur_key] = {}
        end
      elseif cur_key ~= nil then
        local s = norm_content(line)
        if s ~= "" then
          map[cur_key][#map[cur_key] + 1] = s
        end
      end
    end
  end
  f:close()
  return map
end

--- 扫描日记 buffer:返回"改动过的标题"的文字。
--- 规则:
---   * 模板里没有的标题 → 直接计入;
---   * 模板里有的标题 → 该标题下内容与模板不一致(用户改动过)才计入;
---   * 标题被计入时,它的所有上级标题(祖先链)也一并计入,
---     例如新增/改动了 ### 箫 时,上级 ## 音乐 也会进 tags。
local function changed_heading_tags(note)
  local tmpl = template_section_map(note)
  local start = note.frontmatter_end_line or 0
  local lines = vim.api.nvim_buf_get_lines(note.bufnr, start, -1, false)

  -- 带围栏感知地收集所有 level>=2 标题
  local headings = {}
  local in_code = false
  for idx, line in ipairs(lines) do
    if line:match("^```") or line:match("^~~~") then
      in_code = not in_code
    elseif not in_code then
      local lvl = line:match("^(#+)")
      if lvl ~= nil and #lvl >= 2 then
        local text = normalize_heading(line)
        if text ~= "" then
          headings[#headings + 1] = { level = #lvl, text = text, idx = idx }
        end
      end
    end
  end

  local tags = {}
  local stack = {} -- 祖先栈:{ level = , text = }
  for k, h in ipairs(headings) do
    -- 维护祖先栈:弹出 level >= 当前标题的所有栈顶
    while #stack > 0 and stack[#stack].level >= h.level do
      table.remove(stack)
    end
    -- 栈里剩下的都是当前标题的上级(祖先链)
    local ancestors = {}
    for _, a in ipairs(stack) do
      ancestors[#ancestors + 1] = a.text
    end

    local next_idx = (k < #headings) and headings[k + 1].idx or (#lines + 1)
    -- 内容区块:该标题之后到下一个标题之前的所有非空行
    local block = {}
    for idx = h.idx + 1, next_idx - 1 do
      local s = norm_content(lines[idx])
      if s ~= "" then
        block[#block + 1] = s
      end
    end

    local tmpl_block = tmpl[h.text]
    local changed = tmpl_block == nil -- 模板中没有的新标题 → 计入
    if not changed and tmpl_block ~= nil then
      local same = #block == #tmpl_block
      if same then
        for b = 1, #block do
          if block[b] ~= tmpl_block[b] then
            same = false
            break
          end
        end
      end
      changed = not same
    end

    if changed then
      tags[#tags + 1] = h.text
      for _, a in ipairs(ancestors) do
        tags[#tags + 1] = a
      end
    end

    table.insert(stack, { level = h.level, text = h.text })
  end
  return tags
end

return {
  -- 1. 配置 obsidian.nvim
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      -- 即使不启用 nvim-cmp，代码逻辑仍需引用其模块
      "hrsh7th/nvim-cmp",
    },
    keys = {
      -- 搜索与导航
      { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search Obsidian Notes" },
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian Note" },
      { "<leader>oo", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick Switch (Picker)" },
      -- 日记功能
      { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Today's Daily Note" },
      { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Yesterday's Daily Note" },
      -- 模板与链接
      { "<leader>ot", "<cmd>ObsidianTemplate<cr>", desc = "Insert Template" },
      { "<leader>ol", "<cmd>ObsidianLink<cr>", desc = "Link Visual Selection", mode = "v" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show Backlinks" },
      -- 重命名
      { "<leader>or", "<cmd>ObsidianRename<cr>", desc = "Rename the Note" },
    },
    opts = {
      -- 自定义 Frontmatter 生成逻辑:每次保存时执行
      note_frontmatter_func = function(note)
        -- 默认字段:与插件默认行为一致(id/aliases/tags + 保留手写 metadata)
        local out = {
          id = note.id,
          aliases = note.aliases,
          tags = note.tags,
        }
        if note.metadata ~= nil then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end

        -- 仅日记:将改动过的标题文字加入 tags(只增不删,去重)
        if tostring(note.path or ""):match("04_Daily") and note.bufnr ~= nil then
          local seen = {}
          for _, t in ipairs(out.tags) do
            seen[t] = true
          end
          for _, t in ipairs(changed_heading_tags(note)) do
            if not seen[t] then
              table.insert(out.tags, t)
              seen[t] = true
            end
          end
        end

        return out
      end,

      workspaces = {
        {
          name = "chen_note",
          path = "~/chen_note",
        },
      },
      notes_subdir = "00_Inbox",
      log_level = vim.log.levels.INFO,
      -- 1. 核心：锁死所有新笔记的落脚点

      -- 2. 命名逻辑：时间戳-标题
      note_id_func = function(title)
        local name = ""
        if title ~= nil and title ~= "" then
          -- 允许中文、字母、数字、连字符，空格转连字符
          name = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-一-龥]", ""):lower()
        else
          name = "note"
        end
        -- return tostring(os.date("%Y%m%d%H%M")) .. "-" .. name
        return name .. "-" .. tostring(os.date("%Y%m%d%H%M"))
      end,
      daily_notes = {
        folder = "04_Daily",
        date_format = "%Y-%m-%d",
        template = "Templates/Daily_Template.md",
      },
      completion = {
        -- 必须设为 false，防止插件自动去找不存在的 nvim-cmp
        nvim_cmp = false,
        min_chars = 2,
      },
      templates = {
        -- subdir = "Templates",
        folder = "Templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        -- 核心：在这里顺手解决你 {{title}} 会抓取最后一个别名的问题
        substitutions = {
          pure_title = function()
            local name = vim.fn.expand("%:t:r")
            if name == "" or name == nil then
              return "New Note"
            end
            return name
          end,
        },
      },
      attachments = {
        img_folder = "assets",
      },
      ui = {
        enable = true,
        update_debounce = 200,
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
        },
      },
    },
    config = function(_, opts)
      require("obsidian").setup(opts)

      -- 核心 HACK：手动向已加载的 cmp 模块注册 obsidian 源
      -- 这步是为了让 blink.compat 能够通过 require("cmp") 找到并桥接这些源
      local status, cmp = pcall(require, "cmp")
      if status then
        cmp.register_source("obsidian", require("cmp_obsidian").new())
        cmp.register_source("obsidian_new", require("cmp_obsidian_new").new())
        cmp.register_source("obsidian_tags", require("cmp_obsidian_tags").new())
      end

      -- 命令行补全优化
      vim.opt.wildmode = "longest:full,full"
      vim.opt.wildoptions = "pum"
    end,
  },

  -- 2. 配置 blink.cmp 及其兼容层
  {
    "saghen/blink.cmp",
    dependencies = {
      { "saghen/blink.compat", opts = {} }, -- 必须启用兼容层
    },
    opts = {
      sources = {
        -- 将 obsidian 系列源加入默认补全列表
        default = { "lsp", "path", "snippets", "buffer", "obsidian", "obsidian_new", "obsidian_tags" },
        providers = {
          -- 告诉 blink 使用 compat 模块来调用之前手动注册的源
          obsidian = {
            name = "obsidian",
            module = "blink.compat.source",
          },
          obsidian_new = {
            name = "obsidian_new",
            module = "blink.compat.source",
          },
          obsidian_tags = {
            name = "obsidian_tags",
            module = "blink.compat.source",
          },
        },
      },
    },
  },
}
