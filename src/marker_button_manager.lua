-- marker_button_manager.lua
-- Creates the +/- buttons for the zones to add and remove markers

local base = require("src.base")
local zone_manager = require("src.zone_manager")
local marker_manager = require("src.marker_manager")

local marker_button_manager = {}


local BTN_BG = {0, 0, 0, 1}
local BTN_FG = {1, 1, 1, 1}

local BTN_WIDTH = 200
local BTN_HEIGHT = 200
local BTN_FONT = 80

local CREATED_FOR = {}

local function attach_pair_for_zone(zone_guid)
  if not zone_guid or zone_guid == "" then return end
  if CREATED_FOR[zone_guid] then return end

  local zone = getObjectFromGUID(zone_guid)

  local plus_off  = { -0.6, -0.4, 0.2 }
  local minus_off = { -0.6, -0.4, -0.2 }
  local rot = { 0, 180, 0 }

  zone:createButton({
    label = "+",
    click_function = "__add_marker",
    function_owner = Global,
    position = plus_off,
    rotation = rot,
    width = BTN_WIDTH, height = BTN_HEIGHT, font_size = BTN_FONT,
    color = BTN_BG, font_color = BTN_FG,
    tooltip = "Add a marker to this zone"
  })

  zone:createButton({
    label = "-",
    click_function = "__remove_marker",
    function_owner = Global,
    position = minus_off,
    rotation = rot,
    width = BTN_WIDTH, height = BTN_HEIGHT, font_size = BTN_FONT,
    color = BTN_BG, font_color = BTN_FG,
    tooltip = "Remove a marker from this zone"
  })

  CREATED_FOR[zone_guid] = true
end

function marker_button_manager.init()
  local config = base.config()
  attach_pair_for_zone(config.ZONES.money)
  attach_pair_for_zone(config.ZONES.blocks)
end

function __add_marker(object, player_color)
  local zone_guid =  object:getGUID()

  marker_manager.add_markers({
    zone_guid = zone_guid,
    n = 1
  })
end

function __remove_marker(object, player_color)
  local zone_guid =  object:getGUID()

  local removed_a_marker = marker_manager.remove_markers({
    zone_guid = zone_guid,
    n = 1
  })

  if not removed_a_marker then
    base.log_warning({message = "No removable markers in this zone."})
  end
end

return marker_button_manager
