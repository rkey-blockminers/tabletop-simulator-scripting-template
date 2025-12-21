-- character_manager.lua
-- All information about the characters and the character cards

local base = require("src.base")
local zone_manager = require("src.zone_manager")

local character_manager = {}

local CHARACTERS = {
  Pink = {
    guid = "3ccabf",
    color = "Pink",
    voice = 1,
    mind = 6,
    will = 3,
    starting_money = 2,
    zones = {}
  },
  Red = {
    guid = "ca5bb1",
    color = "Red",
    voice = 4,
    mind = 4,
    will = 3,
    starting_money = 3,
    zones = {}
  },
  Green = {
    guid = "d7f274",
    color = "Green",
    voice = 6,
    mind = 6,
    will = 2,
    starting_money = 4,
    zones = {}
  },
  Blue = {
    guid = "e16623",
    color = "Blue",
    voice = 6,
    mind = 2,
    will = 3,
    starting_money = 2,
    zones = {}
  },
  Yellow = {
    guid = "fc4e43",
    color = "Yellow",
    voice = 2,
    mind = 3,
    will = 4,
    starting_money = 1,
    zones = {}
  }
}

local function set_zones_for(colorKey, char)
  local upper = string.upper(colorKey)

  local odName  = upper .. "_OFFICE_DECK"
  local odcName = upper .. "_OFFICE_DISCARD"
  local bdName  = upper .. "_BASEMENT_DECK"
  local bdcName = upper .. "_BASEMENT_DISCARD"

  local od  = zone_manager.find_zone_by_name({ name = odName })
  local odc = zone_manager.find_zone_by_name({ name = odcName })
  local bd  = zone_manager.find_zone_by_name({ name = bdName })
  local bdc = zone_manager.find_zone_by_name({ name = bdcName })

  if od  then char.zones.office_deck      = od:getGUID()  end
  if odc then char.zones.office_discard   = odc:getGUID() end
  if bd  then char.zones.basement_deck    = bd:getGUID()  end
  if bdc then char.zones.basement_discard = bdc:getGUID() end
end

function character_manager.init()
  for color, char in pairs(CHARACTERS) do
    char.zones = char.zones or {}
    set_zones_for(color, char)
  end
end

function character_manager.get_seated_players_with_characters()
  local seated = {}
  for _, player in ipairs(Player.getPlayers() or {}) do
    seated[player.color] = true
  end
  return seated
end

function character_manager.count_seated_players_with_characters()
  local seated = character_manager.get_seated_players_with_characters()
  return base.len({ table = seated })
end

function character_manager.ordered_players()
  local list = {}
  local CI = base.config().COLOR_INDEX
  for _, p in ipairs(Player.getPlayers() or {}) do table.insert(list, p) end
  table.sort(list, function(a,b) return CI[a.color] < CI[b.color] end)
  return list
end

function character_manager.ordered_players_from(args)
  local start_index = args.start_index

  local ordered = character_manager.ordered_players()
  local count   = #ordered

  local result = {}
  for i = 0, count - 1 do
    local idx = ((start_index - 1 + i) % count) + 1
    table.insert(result, ordered[idx])
  end

  return result
end

function character_manager.ordered_colors_from(args)
  local start_index = args.start_index

  local ordered_players = character_manager.ordered_players()
  local count = #ordered_players

  local result = {}
  for i = 0, count - 1 do
    local idx = ((start_index - 1 + i) % count) + 1
    table.insert(result, ordered_players[idx].color)
  end

  return result
end

function character_manager.get_character_by_color(args)
  local color = args.color
  if not color then return nil end
  return CHARACTERS[color]
end

function character_manager.get_character_card_for_color(args)
  local color = args.color
  if not color then return nil end
  local ch = character_manager.get_character_by_color({ color = color })
  if not ch or not ch.guid then return nil end
  return getObjectFromGUID(ch.guid)
end

function character_manager.all_characters()
  return CHARACTERS
end

function character_manager.get_characters_with_seated_players()
  local seated = character_manager.get_seated_players_with_characters()
  local all = character_manager.all_characters()

  local result = {}

  for color, character in pairs(all) do
    if seated[color] then
      result[color] = character
    end
  end

  return result
end

function character_manager.prune_unseated()
  local seated = character_manager.get_seated_players_with_characters()

  for color, character in pairs(CHARACTERS) do
    if not seated[color] then

      local character_card = getObjectFromGUID(character.guid)
      destroyObject(character_card)

      for _, zone_guid in pairs(character.zones) do
        local zone = getObjectFromGUID(zone_guid)
        for _, object in ipairs(zone:getObjects()) do
            destroyObject(object)
        end
      end

    end
  end
end

return character_manager
