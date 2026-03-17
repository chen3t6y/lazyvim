return {
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        -- transform_items 是处理补全项的核心函数
        transform_items = function(_, items)
          local seen = {}
          local out = {}
          for _, item in ipairs(items) do
            -- 如果 label（显示的文字）已经出现过，就跳过它
            if not seen[item.label] then
              seen[item.label] = true
              table.insert(out, item)
            end
          end
          return out
        end,
      },
      -- 下面这段是为了让你看清楚补全到底来自哪里，方便以后排查
      completion = {
        menu = {
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind", "source_name" }, -- 加入 source_name
            },
          },
        },
      },
    },
  },
}
