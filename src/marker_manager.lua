-- marker_manager.lua
-- All marker operations (add, remove, rent etc.)

local base = require("src.base")
local character_manager = require("src.character_manager")
local zone_manager = require("src.zone_manager")

local marker_manager = {}

local function get_bag()
  return getObjectFromGUID(base.config().GUIDS.MARKERS_BAG)
end

local function add_one_marker_randomly_in_zone(args)
  local zone_guid = args.zone_guid
  local jitter_x = args.jitter_x or 4
  local jitter_z = args.jitter_z or 2

  local bag = get_bag()

  local position = zone_manager.get_zone_center_and_yaw({ zone_guid = zone_guid })

  local jitter = Vector(
    (math.random() - 0.5) * jitter_x,
    0,
    (math.random() - 0.5) * jitter_z
  )

  local drop_position = position + Vector(0, 0.1, 0) + jitter

  bag:takeObject({
    position = drop_position,
    rotation = { 0, math.random(0, 359), 0 },
    smooth   = false,
  })

  return true
end

function marker_manager.add_markers(args)
  local zone_guid = args.zone_guid
  local n = args.n
  local wait_time_seconds = args.wait_time_seconds or 0.1
  local jitter_x = args.jitter_x or 4
  local jitter_z = args.jitter_z or 2

  for i = 1, n do
    Wait.time(function()
      add_one_marker_randomly_in_zone({
        zone_guid = zone_guid,
        jitter_x = jitter_x,
        jitter_z = jitter_z,
      })
    end, (i - 1) * wait_time_seconds)
  end
end

function marker_manager.remove_markers(args)
  local zone_guid = args.zone_guid
  local n = args.n
  local wait_time_seconds = args.wait_time_seconds or 0.1

  local bag     = get_bag()
  local objects = zone_manager.get_objects_in_zone({ zone_guid = zone_guid })

  local removed = 0

  for i, object in ipairs(objects) do
    if removed >= n then
      break
    end

    Wait.time(function()
      bag:putObject(object)
    end, (removed) * wait_time_seconds)

    removed = removed + 1
  end

  return removed == n
end

function marker_manager.set_starting_money()
  local money = 0
  for _, player in ipairs(Player.getPlayers() or {}) do
    local character = character_manager.get_character_by_color({ color = player.color })
    if character and character.starting_money then
      money = money + character.starting_money
    end
  end

  marker_manager.add_markers({
    zone_guid = base.config().ZONES.money,
    n = money,
  })
end

function marker_manager.set_starting_rent()
  local count = character_manager.count_seated_players_with_characters()

  marker_manager.add_markers({
    zone_guid = base.config().ZONES.rent,
    n = count,
    jitter_x = 2,
    jitter_z = 1,
  })
end

function marker_manager.get_current_rent()
  local markers = zone_manager.get_objects_in_zone({ zone_guid = base.config().ZONES.rent })
  return base.len({ table = markers })
end

function marker_manager.pay_rent()
  local rent = marker_manager.get_current_rent()

  local markers = zone_manager.get_objects_in_zone({ zone_guid = base.config().ZONES.money })
  local removed = 0

  for _, moneyMarker in ipairs(markers) do
    if removed >= rent then break end
    destroyObject(moneyMarker)
    removed = removed + 1
  end

  return removed >= rent
end

return marker_manager
