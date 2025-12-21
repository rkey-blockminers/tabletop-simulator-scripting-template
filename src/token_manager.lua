-- token_manager.lua
-- Owns all Go-First token movement.

local base = require("src.base")
local character_manager = require("src.character_manager")

local token_manager = {}

local function move_token_to_object(args)
  local targetObj = args.targetObj

  local token = getObjectFromGUID(base.config().GUIDS.GO_FIRST_TOKEN)
  local p = targetObj.getPosition()
  local pos = Vector(p.x, p.y + 2, p.z)

  token:setPositionSmooth(pos, false, false)
end

function token_manager.place_at_index(args)
  local index = args.index

  local all_players = character_manager.ordered_players()

  local player = all_players[index]
  local charCard = character_manager.get_character_card_for_color({ color = player.color })

  move_token_to_object({ targetObj = charCard })
end

return token_manager
