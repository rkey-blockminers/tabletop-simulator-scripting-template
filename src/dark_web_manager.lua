-- dark_web_manager.lua
-- Handles Dark Web browsing and card pickup.

local base = require("src.base")
local card_manager = require("src.card_manager")
local character_manager = require("src.character_manager")
local zone_manager = require("src.zone_manager")

local dark_web_manager = {}

local BROWSE_OFFSET = { x = -0.6,  z = 1.0 }
local COUNT_OFFSET  = { x = -2.6,  z = 1.0 }
local PLUS_OFFSET   = { x = -2.6,  z = 1.8 }
local MINUS_OFFSET  = { x = -2.6,  z = 0.2 }

local BTN_BG_BLACK = {0, 0, 0, 1}
local BTN_FG_WHITE = {1, 1, 1, 1}

local CARD_SPREAD_X = 2.2
local SKIP_OFFSET_X = 3.0

local PICK_BUTTON_POS  = {0, 0.3, 3}
local PICK_BUTTON_SIZE = {width = 800, height = 300, font_size = 220}

local BROWSE_SELECTION_OFFSET = {3.0, -2.0, -13.0}

local STATE = {
  count = 5,
  reveal = {},
}

local function create_browse_buttons()
  local config = base.config()
  local zone_guid = config.ZONES.dark_web
  local zone = getObjectFromGUID(zone_guid)
  if not zone then return end

  local button_height = -0.5
  local rotation = {0, 180, 0}

  -- BROWSE
  zone:createButton({
    label = "BROWSE",
    click_function = "_browse",
    function_owner = Global,
    position = { BROWSE_OFFSET.x, button_height, BROWSE_OFFSET.z },
    rotation = rotation,
    width = 1200,
    height = 360,
    font_size = 240,
    color = BTN_BG_BLACK,
    font_color = BTN_FG_WHITE,
    tooltip = "Reveal " .. tostring(STATE.count) .. " cards"
  })

  -- COUNT
  zone:createButton({
    label = tostring(STATE.count),
    click_function = "_browse",
    function_owner = Global,
    position = { COUNT_OFFSET.x, button_height, COUNT_OFFSET.z },
    rotation = rotation,
    width = 560,
    height = 360,
    font_size = 240,
    color = BTN_BG_BLACK,
    font_color = BTN_FG_WHITE
  })

  -- PLUS
  zone:createButton({
    label = "+",
    click_function = "_increase_browse_count",
    function_owner = Global,
    position = { PLUS_OFFSET.x, button_height, PLUS_OFFSET.z },
    rotation = rotation,
    width = 520,
    height = 280,
    font_size = 220,
    color = BTN_BG_BLACK,
    font_color = BTN_FG_WHITE
  })

  -- MINUS
  zone:createButton({
    label = "-",
    click_function = "_decrease_browse_count",
    function_owner = Global,
    position = { MINUS_OFFSET.x, button_height, MINUS_OFFSET.z },
    rotation = rotation,
    width = 520,
    height = 280,
    font_size = 220,
    color = BTN_BG_BLACK,
    font_color = BTN_FG_WHITE
  })
end

local function discard_to_dark_web_archives(args)
  local cards = args.cards

  for _, card in ipairs(cards) do
    card:clearButtons()
    card_manager.add_to_discard_pile({
      card = card,
      deck_zone_guid = base.config().ZONES.dark_web_archives
    })
  end

  STATE.reveal = {}
end

local function restack_archives()
  local config = base.config()
  local dark_web = card_manager.find_pile_in_zone({
    zone_guid = config.ZONES.dark_web
  })

  local dark_web_archives = card_manager.find_pile_in_zone({
    zone_guid = config.ZONES.dark_web_archives
  })

  if not dark_web_archives then return end

  local pos_deck, yaw_deck = zone_manager.get_zone_center_and_yaw({
    zone_guid = config.ZONES.dark_web_archives
  })

  if dark_web_archives.is_face_down == false and dark_web_archives.flip then
    dark_web_archives:flip()
  end

  Wait.time(function()
    dark_web_archives:shuffle()
  end, 0.8)

  local deck_count = dark_web and card_manager.count_cards({ deck = dark_web }) or 0

  if deck_count > 0 then
    Wait.time(function()
      dark_web:setRotationSmooth({180, yaw_deck, 0}, false, true)
      dark_web:setPositionSmooth(
        dark_web_archives:getPosition() + Vector(0, 3, 0),
        false,
        true
      )
    end, 1.2)
  end

  local pos_deck, yaw_deck = zone_manager.get_zone_center_and_yaw({
    zone_guid = config.ZONES.dark_web
  })

  Wait.time(function()
    dark_web_archives:setRotationSmooth({180, yaw_deck or 0, 0}, false, true)
    dark_web_archives:setPositionSmooth(pos_deck, false, true)
  end, 2.2)
end

function dark_web_manager.set_count(args)
  local n = args.n
  local v = tonumber(n)
  if not v then return end

  STATE.count = math.max(1, math.min(12, v))

  local config = base.config()
  local zone = getObjectFromGUID(config.ZONES.dark_web)

  zone.editButton({
    index   = 0,
    tooltip = "Reveal " .. tostring(STATE.count) .. " cards"
  })
  zone.editButton({
    index = 1,
    label = tostring(STATE.count)
  })
end

function dark_web_manager.get_count()
  return STATE.count or 1
end

local function do_browse_reveal(args)
  local player_color = args.player_color

  local n = STATE.count or 1
  local config = base.config()

  local deck = card_manager.find_pile_in_zone({
    zone_guid = config.ZONES.dark_web
  })
  if not deck then return end

  local hand = Player[player_color].getHandTransform(1)
  local yaw = hand.rotation.y
  local yaw_rad = math.rad(yaw)

  local forward = {
    x = math.sin(yaw_rad),
    z = math.cos(yaw_rad),
  }
  local right = {
    x = forward.z,
    z = -forward.x,
  }
  local base_pos = {
    x = hand.position.x + forward.x * 7,
    y = hand.position.y + 2,
    z = hand.position.z + forward.z * 7,
  }

  local face_yaw = (yaw + 180) % 360

  local function add_pick_button(card)
    card:createButton({
      label = "PICK",
      click_function = "_pick_card",
      function_owner = Global,
      position = PICK_BUTTON_POS,
      rotation = {0, 0, 0},
      width = PICK_BUTTON_SIZE.width,
      height = PICK_BUTTON_SIZE.height,
      font_size = PICK_BUTTON_SIZE.font_size,
      color = BTN_BG_BLACK,
      font_color = BTN_FG_WHITE,
      tooltip = "Take this card",
    })
  end

  local mid = (n + 1) / 2
  local revealed = {}

  for i = 1, n do
    local offset = (i - mid) * CARD_SPREAD_X

    local px = base_pos.x + right.x * offset
    local py = base_pos.y
    local pz = base_pos.z + right.z * offset

    local delay = (i - 1) * 0.1

    Wait.time(function()
      local card = deck:takeObject({
        position = {px, py, pz},
        rotation = {0, face_yaw, 0},
        smooth   = true,
        flip     = true,
        index    = 0,
      })
      if card then
        card:setRotationSmooth({30, face_yaw, 0}, false, true)
        card:setLock(true)
        add_pick_button(card)
        table.insert(revealed, card)
      end
    end, delay)
  end

  STATE.reveal.cards = revealed
end

function dark_web_manager.browse(args)
  local player_color = args.player_color
  local config = base.config()

  local zone = getObjectFromGUID(config.ZONES.dark_web)
  if not zone then return end
  zone:clearButtons()

  local n = STATE.count or 1

  local deck = card_manager.find_pile_in_zone({
    zone_guid = config.ZONES.dark_web
  })
  local deck_count = deck and card_manager.count_cards({ deck = deck }) or 0

  if deck_count < n then
    Wait.time(function()
      restack_archives()
    end, 0.1)

    Wait.time(function()
      do_browse_reveal({player_color = player_color})
    end, 3.5)
  else
    do_browse_reveal({player_color = player_color})
  end
end

function dark_web_manager.pick(args)
  local card_obj = args.card_obj
  local player_color = args.player_color

  if not card_obj or not player_color then return end

  card_obj:clearButtons()

  local character = character_manager.get_character_by_color({
    color = player_color
  })
  if not character then return end

  if card_manager.is_basement_card({ card = card_obj }) then
    card_manager.add_to_deck({
      card = card_obj,
      deck_zone_guid = character.zones.basement_deck
    })
  elseif card_manager.is_office_card({ card = card_obj }) then
    card_manager.add_to_deck({
      card = card_obj,
      deck_zone_guid = character.zones.office_deck
    })
  end

  local rest = {}
  for _, c in ipairs(STATE.reveal.cards or {}) do
    if c ~= card_obj then
      c:clearButtons()
      table.insert(rest, c)
    end
  end

  discard_to_dark_web_archives({ cards = rest })
  create_browse_buttons()
end

function _pick_card(obj, player_color)
  dark_web_manager.pick({
    card_obj = obj,
    player_color = player_color
  })
end

function _browse(obj, player_color)
  dark_web_manager.browse({ player_color = player_color })
end

function _increase_browse_count()
  dark_web_manager.set_count({ n = dark_web_manager.get_count() + 1 })
end

function _decrease_browse_count()
  dark_web_manager.set_count({ n = dark_web_manager.get_count() - 1 })
end

function dark_web_manager.init()
  create_browse_buttons()
end

return dark_web_manager
