-- base.lua
-- Most basic functionalities shared by almost all scripts

local base = {}

function base.log_info(args)
  local message = args.message
  broadcastToAll(message, CONFIG.COLORS.RGB.INFO)
end

function base.log_warning(args)
  local message = args.message
  broadcastToAll(message, CONFIG.COLORS.RGB.WARN)
end

function base.len(args)
  local table = args.table
  local n = 0
  for _ in pairs(table) do
    n = n + 1
  end
  return n
end

function base.has_tag(args)
  local object = args.object
  local tag = args.tag

  for _, t in ipairs(object:getTags()) do
    if t == tag then
      return true
    end
  end
  return false
end

function base.config()
  if CONFIG ~= nil then
    return CONFIG
  end

  local cfg = Global.getTable("CONFIG")
  if cfg ~= nil then
    return cfg
  end

  error("CONFIG is not initialized (base.config())")
end

return base
