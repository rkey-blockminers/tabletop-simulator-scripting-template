-- start_of_day_draw_manager.lua
-- Spawns buttons during start of day that draw cards from either deck for a player

local base              = require("src.base")
local character_manager = require("src.character_manager")
local card_manager      = require("src.card_manager")

local start_of_day_draw_manager = {}

local start_of_day_queue = {
  active = false,
  order = {},
  idx = 0,
  zones_with_buttons = {},
  info_by_zone = {},
}

local function clear_zone_buttons()
  for _, zone_guid in ipairs(start_of_day_queue.zones_with_buttons) do
    local object = getObjectFromGUID(zone_guid)
    if object and object.clearButtons then
      object:clearButtons()
    end
  end
  start_of_day_queue.zones_with_buttons = {}
  start_of_day_queue.info_by_zone = {}
end

local function attach_choice_buttons_for(args)
  local color = args.color

  local function attach(args)
    local zone_guid = args.zone_guid
    local label = args.label
    local button_color = args.bg
    local text_color = args.fg
    local config = base.config()

    local zone = getObjectFromGUID(zone_guid)
    local zone_rot = zone:getRotation()
    local zone_yaw = (zone_rot and zone_rot.y) or 0

    local player = Player[color]
    local player_hand_transform = player:getHandTransform(1)
    local player_yaw  = player_hand_transform.rotation.y or 0
    if player_yaw < 0 then
      player_yaw = player_yaw + 360
    end

    -- Button orientation for this player
    local buttonYaw = player_yaw
      and ((player_yaw - zone_yaw + 180) % 360)
      or  ((360 - zone_yaw) % 360)

    zone:createButton({
      label = label,
      click_function = "__start_of_day_draw",
      function_owner = Global,
      position = {0, 0, 0},
      rotation = {0, buttonYaw, 0},
      width = 820,
      height = 300,
      font_size = 150,
      color = button_color,
      font_color = text_color,
      tooltip = "Draw from " .. label .. " (" .. color .. ")"
    })

    table.insert(start_of_day_queue.zones_with_buttons, zone_guid)
    start_of_day_queue.info_by_zone[zone_guid] = {
      color = color,
      zone  = zone_guid,
      label = label,
    }

    return true
  end

  local character = character_manager.get_character_by_color({ color = color })

  attach({
    zone_guid = character.zones.office_deck,
    label = "OFFICE",
    bg = config.COLORS.RGBA.CYAN,
    fg = config.COLORS.RGBA.WHITE,
  })

  attach({
    zone_guid = character.zones.basement_deck,
    label = "BASEMENT",
    bg = config.COLORS.RGBA.MAGENTA,
    fg = config.COLORS.RGBA.WHITE,
  })

  base.log_info({ message = color .. ": choose a deck to draw from." })
  return true
end

local function advance_start_of_day_queue()
  clear_zone_buttons()

  start_of_day_queue.idx = start_of_day_queue.idx + 1
  local color = start_of_day_queue.order[start_of_day_queue.idx]

  if not color then
    start_of_day_queue.active = false
    pcall(function() Global.call("_next_phase") end)
    return
  end

  attach_choice_buttons_for({ color = color })
end

function __start_of_day_draw(object, player_color)
  local zone_guid = object:getGUID()
  local info = start_of_day_queue.info_by_zone[zone_guid]

  if player_color ~= info.color then
    broadcastToColor("This choice is for " .. info.color .. ".", player_color, {1, 0.5, 0.5})
    return
  end

  local character = character_manager.get_character_by_color({ color = info.color })
  local will = character.will
  local zones = character.zones

  local deck_zone, discard_zone
  if info.label == "OFFICE" then
    deck_zone, discard_zone = zones.office_deck, zones.office_discard
  else
    deck_zone, discard_zone = zones.basement_deck, zones.basement_discard
  end

  card_manager.draw_from_deck({
    deck_zone_guid = deck_zone,
    discard_zone_guid = discard_zone,
    count = will,
    to_color = info.color,
  })

  clear_zone_buttons()
  advance_start_of_day_queue()
end

function start_of_day_draw_manager.begin_start_of_day_queue(args)
  if start_of_day_queue.active then return end

  start_index = args.start_index

  start_of_day_queue.active = true
  start_of_day_queue.order = character_manager.ordered_colors_from({ start_index = start_index })
  start_of_day_queue.idx = 0

  advance_start_of_day_queue()
end

return start_of_day_draw_manager
