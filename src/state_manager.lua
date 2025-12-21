-- state_manager.lua
-- Owns the phase/state machine and the main loop. Builds the UI button, manages
-- BM.state, and calls out to other managers to actually do things.

local base = require("src.base")
local card_manager              = require("src.card_manager")
local character_manager         = require("src.character_manager")
local dark_web_manager          = require("src.dark_web_manager")
local encounter_card_manager    = require("src.encounter_card_manager")
local marker_manager            = require("src.marker_manager")
local played_cards_manager      = require("src.played_cards_manager")
local start_of_day_draw_manager = require("src.start_of_day_draw_manager")
local token_manager             = require("src.token_manager")
local zone_manager              = require("src.zone_manager")

local state_manager = {}

local go_first_idx = 1
local day = 0
local phase = 0

function state_manager.update_button()
  config = base.config()
  UI.setAttribute("bm_btn", "text", config.PHASES.TEXT[phase])
  UI.setAttribute("bm_btn", "tooltip", config.PHASES.TOOLTIP[phase])
  
  -- Cannot click button if phase is 6 or 2
  if phase == 6 or phase == 2 then
    UI.setAttribute("bm_btn", "interactable", "false")
    return
  end

  -- Unless phase is three, button is interactable
  if phase ~= 3 then
    UI.setAttribute("bm_btn", "interactable", "true")
    return
  end

  local anyCards = false
  for _, player in ipairs(Player.getPlayers() or {}) do
    local cards = player:getHandObjects()
    if #cards > 0 then
      anyCards = true
      break
    end
  end

  -- If any cards, not interactable, otherwise interactable
  UI.setAttribute("bm_btn", "interactable", anyCards and "false" or "true")
end

local function announce_day_and_phase()
  local config = base.config()
  base.log_info({message = config.PHASES.DESC[phase]})
  base.log_warning({message = string.format("--- Day %d, %s ---", day, config.PHASES.NAMES[phase])})
end

local function rotate_go_first_index()
  local n = character_manager.count_seated_players_with_characters()
  go_first_idx = (go_first_idx % n) + 1
  token_manager.place_at_index({ index = go_first_idx })
end

function state_manager.init()
  UI.setXml([[
    <Panel id="bm_ui_root" rectAlignment="LowerRight" width="380" height="60" offsetXY="-90 8">
      <HorizontalLayout>
        <Button id="bm_btn" onClick="_next_phase" text="PERFORM SETUP"
          fontSize="24" fontStyle="Bold" width="360" height="60"
          color="rgba(234,213,0,255)" textColor="rgba(0,0,0,255)" interactable="true"/>
      </HorizontalLayout>
    </Panel>
  ]])
  state_manager.update_button()
end

local function shuffle_all_character_decks()
  local all_characters = character_manager.get_characters_with_seated_players()

  for color, character in pairs(all_characters) do
    card_manager.shuffle({
        deck_zone_guid = character.zones.office_deck
    })

    card_manager.shuffle({
        deck_zone_guid = character.zones.basement_deck
    })
  end
end

function state_manager.next_phase()
  local config = base.config()

  -- Phase 0 -> 1: Perform setup
  if phase == 0 then
    phase = 1

    -- Prepare table & subsystems
    character_manager.prune_unseated()

    -- Place token at current go_first_idx (highlight on initial placement)
    token_manager.place_at_index({ index = go_first_idx })

    card_manager.move_pile_to_zone({
      from_zone_guid = config.ZONES.dark_web_office_cards,
      to_zone_guid   = config.ZONES.dark_web,
    })

    card_manager.move_pile_to_zone({
      from_zone_guid = config.ZONES.dark_web_basement_cards,
      to_zone_guid   = config.ZONES.dark_web,
    })

    Wait.time(function()
      shuffle_all_character_decks()
      card_manager.shuffle({deck_zone_guid = config.ZONES.dark_web})
      card_manager.shuffle({ deck_zone_guid = config.ZONES.encounter_cards })
    end, 1.0)

    Wait.time(function()
      dark_web_manager.init()
    end, 1.2)

    Wait.time(function()
      marker_manager.set_starting_rent()
    end, 1.4)

    Wait.time(function()
      marker_manager.set_starting_money()
    end, 2.0)

  -- Phase 1 or 5 -> 2: New Day, deal encounters, then SOD choices
  elseif phase == 1 or phase == 5 then
    phase = 2
    day = day + 1

    local order = character_manager.ordered_colors_from({ start_index = go_first_idx })
    encounter_card_manager.deal_encounters({
      order             = order,
      amount            = 1,
      wait_time_seconds = 1,
    })

    Wait.time(function()
      start_of_day_draw_manager.begin_start_of_day_queue({start_index = go_first_idx})
    end, (#order * 1) + 0.5)

  -- Phase 2 -> 3: Leave SOD into Workday
  elseif phase == 2 then
    phase = 3

  -- Phase 3 -> 4: End Workday -> Cleanup
  elseif phase == 3 then
    phase = 4
    played_cards_manager.discard_all_played_cards()
    encounter_card_manager.sweep_encounters_to_discard()

  -- Phase 4 -> 5 or 6: Pay Rent
  elseif phase == 4 then
    local paid = marker_manager.pay_rent()
    if paid then
      phase = 5
      rotate_go_first_index()
    else
      phase = 6
    end
  end

  state_manager.update_button()
  announce_day_and_phase()
end

return state_manager
