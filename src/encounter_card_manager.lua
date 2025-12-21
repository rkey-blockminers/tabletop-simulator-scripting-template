-- encounter_card_manager.lua
-- Responsible for larger encounter card operations

local base = require("src.base")
local card_manager = require("src.card_manager")
local zone_manager = require("src.zone_manager")

local encounter_card_manager = {}

function encounter_card_manager.deal_encounters(args)
  local order = args.order
  local amount = args.amount
  local wait_time_seconds = args.wait_time_seconds
  local config = base.config()

  for i, color in ipairs(order) do
    Wait.time(function()
      card_manager.draw_from_deck({
        deck_zone_guid = config.ZONES.encounter_cards,
        discard_zone_guid = config.ZONES.encounter_discard_pile,
        count = amount,
        to_color = color,
      })
    end, (i - 1) * wait_time_seconds)
  end
end

local function is_encounter_card_in_play(args)
  object = args.object
  if not card_manager.is_encounter_card({ card = object }) then
    return false
  end
  if zone_manager.is_in_zone({object = object, zone_guid = config.ZONES.encounter_cards}) then
    return false
  end
  if zone_manager.is_in_zone({object = object, zone_guid = config.ZONES.encounter_discard_pile}) then
    return false
  end
  return true
end

function encounter_card_manager.sweep_encounters_to_discard()
  local config = base.config()
  local discard = getObjectFromGUID(config.ZONES.encounter_discard_pile)

  local target_position = discard:getPosition() + Vector(0, 2, 0)
  local zone_rotation = discard:getRotation()
  local target_rotation = { zone_rotation.x, (zone_rotation.y + 180) % 360, zone_rotation.z }

  for _, object in ipairs(getAllObjects()) do
    if is_encounter_card_in_play({ object = object }) then
      object:setPositionSmooth(target_position, false, true)
      object:setRotationSmooth(target_rotation, false, true)
    end
  end
end

return encounter_card_manager
