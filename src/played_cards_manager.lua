-- played_cards_manager.lua
-- Keeps track of all basement and office cards played

local base = require("src.base")
local card_manager = require("src.card_manager")
local character_manager = require("src.character_manager")
local zone_manager = require("src.zone_manager")

local played_cards_manager = {}

local played_cards = {
  by_color = {}
}

local card_owner = {}

function played_cards_manager.card_played(args)
  local color = args.color
  local card  = args.card
  local guid  = card:getGUID()

  if card_owner[guid] then return end

  card_owner[guid] = color

  played_cards.by_color[color] = played_cards.by_color[color] or {}
  table.insert(played_cards.by_color[color], guid)
end

function played_cards_manager.discard_all_played_cards()
  local config = base.config()

  for color, card_guids in pairs(played_cards.by_color or {}) do
    local character = character_manager.get_character_by_color({ color = color })

    for _, card_guid in ipairs(card_guids) do
      local card = getObjectFromGUID(card_guid)

      -- Adding if card because a card "disappears" if it now instead in a deck
      if card and not zone_manager.is_in_zone({ object = card, zone_guid = config.ZONES.viruses }) and
         not zone_manager.is_in_zone({ object = card, zone_guid = config.ZONES.dark_web }) and
         not zone_manager.is_in_zone({ object = card, zone_guid = config.ZONES.dark_web_archives }) then

        if card_manager.is_basement_card({ card = card }) then
          card_manager.add_to_discard_pile({
            card = card,
            deck_zone_guid = character.zones.basement_discard
          })
        elseif card_manager.is_office_card({ card = card }) then
          card_manager.add_to_discard_pile({
            card = card,
            deck_zone_guid = character.zones.office_discard
          })
        end

      end
    end
  end

  played_cards.by_color = {}
  card_owner = {}
end

return played_cards_manager
