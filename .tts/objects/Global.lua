-- Global.lua
-- Config for the game and global calls

local character_manager       = require("src.character_manager")
local dark_web_manager        = require("src.dark_web_manager")
local marker_button_manager   = require("src.marker_button_manager")
local played_cards_manager    = require("src.played_cards_manager")
local state_manager           = require("src.state_manager")
local snap_point_manager      = require("src.snap_point_manager")

CONFIG = {
  TAGS = {
    ENCOUNTER     = "ENCOUNTER_CARD",
    OFFICE_CARD   = "OFFICE_CARD",
    BASEMENT_CARD = "BASEMENT_CARD",
  },

  COLORS = {
    RGBA = {
      YELLOW   = {234/255, 213/255,   0/255, 1},
      CYAN     = { 10/255, 189/255, 198/255, 1},
      MAGENTA  = {234/255,   0/255, 217/255, 1},
      WHITE    = {1, 1, 1, 1},
      BLACK    = {0, 0, 0, 1},
      RED      = {1, 0, 0, 1},

      INFO     = {0.6, 0.9, 1, 1},
      WARN     = {1, 0.5, 0.5, 1},
      DISABLED = {0.7, 0.7, 0.7, 1},

      UI = {
        BUTTON_BG = {0, 0, 0, 1},
        BUTTON_FG = {1, 1, 1, 1},
      },
    },

    RGB = {
      YELLOW   = {1, 1, 0},
      INFO     = {0.6, 0.9, 1},
      WARN     = {1, 0.5, 0.5},
      WHITE    = {1, 1, 1},
      BLACK    = {0, 0, 0},
      RED      = {1, 0, 0},
    },
  },

  ZONES = {
    blocks  = "655257",
    money   = "434dd8",
    rent    = "c0ec2d",
    viruses = "cd1b95",

    encounter_cards         = "2a317f",
    encounter_discard_pile  = "d58178",
    dark_web                = "753a78",
    dark_web_archives       = "e35104",
    dark_web_basement_cards = "a1fd00",
    dark_web_office_cards   = "741ba6",
  },

  GUIDS = {
    MARKERS_BAG        = "c5c97b",
    OFFICE_BOARD       = "269b97",
    GO_FIRST_TOKEN     = "2f327e",
  },

  SEAT_ORDER = {
    "White", "Brown", "Red", "Orange", "Yellow", "Green",
    "Teal", "Blue", "Purple", "Pink", "Grey", "Black"
  },

  COLOR_INDEX = {
    White=1,Brown=2,Red=3,Orange=4,Yellow=5,
    Green=6,Teal=7,Blue=8,Purple=9,Pink=10,Grey=11,Black=12
  },

  PHASES = {
    NAMES = {
      [0] = "Pre-Game",
      [1] = "Setup",
      [2] = "Start Of Day",
      [3] = "Workday",
      [4] = "Cleanup",
      [5] = "Pay Rent",
      [6] = "Game Over",
    },
    TEXT = {
      [0] = "PERFORM SETUP",
      [1] = "START GAME",
      [2] = "DRAWING CARDS...",
      [3] = "END WORKDAY",
      [4] = "PAY RENT",
      [5] = "START THE NEXT DAY",
      [6] = "GAME OVER",
    },
    TOOLTIP = {
      [0] = "Click after all players are seated to perform setup.",
      [1] = "Click to start the game.",
      [2] = "Waiting for a selection from all players.",
      [3] = "Can be clicked when all cards are played to perform cleanup.",
      [4] = "Click to attempt to pay rent.",
      [5] = "Click to start the next day",
      [6] = "Rent could not be paid.",
    },
    DESC = {
      [0] = "Click PERFORM SETUP",
      [1] = "Table is prepared! Click START GAME when ready.",
      [2] = "Encounter cards dealt, choose OFFICE/BASEMENT.",
      [3] = "Play cards one at a time, around the table.",
      [4] = "Cleanup completed.",
      [5] = "Rent was paid successfully!",
      [6] = "Rent could not be paid.",
    },
  },
}

local function is_card_like(obj)
  return obj and (obj.tag == "Card" or obj.tag == "CardCustom")
end

function _next_phase(player, _, _)
  state_manager.next_phase()
end

function onObjectDrop(player_color, obj)
  if not is_card_like(obj) then return end
  played_cards_manager.card_played({color = player_color, card = obj})
  state_manager.update_button()
end

function onLoad()
  Global.setTable("CONFIG", CONFIG)

  character_manager.init()
  marker_button_manager.init()
  state_manager.init()
  snap_point_manager.recreate_all_snap_points()
end

function onUpdate()
  -- Not used
end

return CONFIG
