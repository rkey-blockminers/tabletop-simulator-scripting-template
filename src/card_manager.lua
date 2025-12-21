-- card_manager.lua
-- Basic card operations (draw, discard, etc.)

local base = require("src.base")
local zone_manager = require("src.zone_manager")

local card_manager = {}

function card_manager.is_card_like(args)
  local object = args.object

  if not object then
    return false
  end

  return object.tag == "Card" or object.tag == "CardCustom"
end

function card_manager.is_office_card(args)
  local card = args.card
  return base.has_tag({ object = card, tag = CONFIG.TAGS.OFFICE_CARD })
end

function card_manager.is_basement_card(args)
  local card = args.card
  return base.has_tag({ object = card, tag = CONFIG.TAGS.BASEMENT_CARD })
end

function card_manager.is_encounter_card(args)
  local card = args.card
  return base.has_tag({ object = card, tag = CONFIG.TAGS.ENCOUNTER })
end

function card_manager.is_dark_web_card(args)
  local card = args.card
  return base.has_tag({ object = card, tag = CONFIG.TAGS.BASEMENT_CARD })
    or base.has_tag({ object = card, tag = CONFIG.TAGS.OFFICE_CARD })
end

function card_manager.find_pile_in_zone(args)
  local zone_guid = args.zone_guid

  local zone = getObjectFromGUID(zone_guid)

  for _, object in ipairs(zone:getObjects()) do
    if object.tag == "Deck" or card_manager.is_card_like({ object = object }) then
      return object
    end
  end
end

function card_manager.count_cards(args)
  local deck = args.deck

  if deck == nil then
    return 0
  end

  if card_manager.is_card_like({ object = deck }) then
    return 1
  elseif deck.tag == "Deck" then
    return deck:getQuantity()
  end
  return 0
end

function card_manager.set_face_down_and_align(args)
  local object    = args.object
  local zone_guid = args.zone_guid

  local _, yaw = zone_manager.get_zone_center_and_yaw({ zone_guid = zone_guid })

  if object.is_face_down ~= true and object.flip then
    object:flip()
  end

  object:setRotationSmooth({180, yaw, 0}, false, true)
end

function card_manager.shuffle(args)
  local deck_zone_guid = args.deck_zone_guid
  local pile = card_manager.find_pile_in_zone({ zone_guid = deck_zone_guid })

  pile:shuffle()
  card_manager.set_face_down_and_align({
    object    = pile,
    zone_guid = deck_zone_guid
  })
end

local function add_to_pile(args)
  local card = args.card
  local deck_zone_guid  = args.deck_zone_guid
  local face_down = args.face_down

  local pos, yaw = zone_manager.get_zone_center_and_yaw({
      zone_guid = deck_zone_guid
  })

  card:setLock(false)

  local x_rot, y_rot
  if face_down then
    x_rot = 180
    y_rot = yaw or 0
  else
    x_rot = 0
    y_rot = (yaw or 0) + 180
  end

  card:setRotationSmooth({x_rot, y_rot % 360, 0}, false, true)
  card:setPositionSmooth(pos + Vector(0, 0.6, 0), false, true)
end

function card_manager.add_to_deck(args)
  add_to_pile({
    card = args.card,
    deck_zone_guid = args.deck_zone_guid,
    face_down = true,
  })
end

function card_manager.add_to_discard_pile(args)
  add_to_pile({
    card = args.card,
    deck_zone_guid = args.deck_zone_guid,
    face_down = false,
  })
end

function card_manager.move_pile_to_zone(args)
  local from_zone_guid = args.from_zone_guid
  local to_zone_guid = args.to_zone_guid

  local pile = card_manager.find_pile_in_zone({ zone_guid = from_zone_guid })

  local to_position, to_yaw = zone_manager.get_zone_center_and_yaw({
    zone_guid = to_zone_guid
  })

  pile:setPositionSmooth(to_position, false, true)
  pile:setRotationSmooth({180, to_yaw or 0, 0}, false, true)
end

function card_manager.reshuffle_discard_into_deck(args)
  local deck_zone_guid = args.deck_zone_guid
  local discard_zone_guid = args.discard_zone_guid

  local discard_pile = card_manager.find_pile_in_zone({ zone_guid = discard_zone_guid })

  if not discard_pile then return end -- No discard pile to shuffle

  if discard_pile.is_face_down ~= true then
    discard_pile:flip()
  end

  Wait.time(function()
    card_manager.move_pile_to_zone({
      from_zone_guid = discard_zone_guid,
      to_zone_guid = deck_zone_guid
    })
  end, 0.3)

  Wait.time(function()
    discard_pile:shuffle()
  end, 0.6)
end


function card_manager.draw_from_deck(args)
  local deck_zone_guid    = args.deck_zone_guid
  local discard_zone_guid = args.discard_zone_guid
  local count             = args.count
  local to_color          = args.to_color

  local deck = card_manager.find_pile_in_zone({ zone_guid = deck_zone_guid })
  local avail = card_manager.count_cards({ deck = deck })

  -- If enough cards, just deal and we're done
  if avail >= count then
    deck:deal(count, to_color)
    return count
  end

  local dealt = 0
  if avail > 0 then
    deck:deal(avail, to_color)
    dealt = avail
  end

  local remaining = count - dealt

  -- Reshuffle discard pile into deck
  card_manager.reshuffle_discard_into_deck({
    deck_zone_guid    = deck_zone_guid,
    discard_zone_guid = discard_zone_guid
  })

  Wait.time(function()
    local new_deck = card_manager.find_pile_in_zone({ zone_guid = deck_zone_guid })
    local new_avail = card_manager.count_cards({ deck = new_deck })
    local take = math.min(remaining, new_avail)

    if take > 0 then
      new_deck:deal(take, to_color)
    end
  end, 1.5)

  return dealt
end

return card_manager
