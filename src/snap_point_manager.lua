-- snap_point_manager.lua
-- Spawns all required snap points

local snap_point_manager = {}

local function snap_point(x, z, ry, tag_list)
  return {
    position = {x, 0, z},
    rotation = {0, ry},
    rotation_snap = (ry ~= nil),
    tags = tag_list
  }
end

local SHARED = {
  office_game_board    = snap_point( -3.5,  0, 180, {"OFFICE_GAME_BOARD"}),
  basement_game_board  = snap_point(  3.5,  0, 180, {"BASEMENT_GAME_BOARD"}),

  encounters           = snap_point( -9.0,  0, 180, {"ENCOUNTER_CARD"}),
  encounters_discard   = snap_point(-12.0,  0, 180, {"ENCOUNTER_CARD"}),

  dark_web             = snap_point(  9.0,  0, 180, {"OFFICE_CARD", "BASEMENT_CARD"}),
  dark_web_archives    = snap_point(  12.0, 0, 180, {"OFFICE_CARD", "BASEMENT_CARD"}),

  virus_one            = snap_point(  1.0, -7.0,  180, {"BASEMENT_CARD"}),
  virus_two            = snap_point(  3.5, -7.0,  180, {"BASEMENT_CARD"}),
  virus_three          = snap_point(  6.0, -7.0,  180, {"BASEMENT_CARD"}),
  virus_four           = snap_point(  1.0, -10.3, 180, {"BASEMENT_CARD"}),
  virus_five           = snap_point(  3.5, -10.3, 180, {"BASEMENT_CARD"}),
  virus_six            = snap_point(  6.0, -10.3, 180, {"BASEMENT_CARD"}),
}

local PLAYERS = {
  Gary = {
    basement_discard = snap_point( -9.5, -15.0, 180, {"BASEMENT_CARD"}),
    basement         = snap_point(-12.5, -15.0, 180, {"BASEMENT_CARD"}),
    character_card   = snap_point(-15.5, -15.0, 180, {"CHARACTER_CARD"}),
    office           = snap_point(-18.5, -15.0, 180, {"OFFICE_CARD"}),
    office_discard   = snap_point(-21.5, -15.0, 180, {"OFFICE_CARD"}),
  },
  Jon = {
    basement_discard = snap_point(-25.0, -3.0, 270, {"BASEMENT_CARD"}),
    basement         = snap_point(-25.0,  0.0, 270, {"BASEMENT_CARD"}),
    character_card   = snap_point(-25.0,  3.0, 270, {"CHARACTER_CARD"}),
    office           = snap_point(-25.0,  6.0, 270, {"OFFICE_CARD"}),
    office_discard   = snap_point(-25.0,  9.0, 270, {"OFFICE_CARD"}),
  },
  Nivek = {
    basement_discard = snap_point(-21.5,  15.0,   0, {"BASEMENT_CARD"}),
    basement         = snap_point(-18.5,  15.0,   0, {"BASEMENT_CARD"}),
    character_card   = snap_point(-15.5,  15.0,   0, {"CHARACTER_CARD"}),
    office           = snap_point(-12.5,  15.0,   0, {"OFFICE_CARD"}),
    office_discard   = snap_point( -9.5,  15.0,   0, {"OFFICE_CARD"}),
  },
  Adriana = {
    basement_discard = snap_point(  9.5,  15.0,   0, {"BASEMENT_CARD"}),
    basement         = snap_point( 12.5,  15.0,   0, {"BASEMENT_CARD"}),
    character_card   = snap_point( 15.5,  15.0,   0, {"CHARACTER_CARD"}),
    office           = snap_point( 18.5,  15.0,   0, {"OFFICE_CARD"}),
    office_discard   = snap_point( 21.5,  15.0,   0, {"OFFICE_CARD"}),
  },
  Satoru = {
    basement_discard = snap_point( 25.0,  3.0,  90, {"BASEMENT_CARD"}),
    basement         = snap_point( 25.0,  0.0,  90, {"BASEMENT_CARD"}),
    character_card   = snap_point( 25.0, -3.0,  90, {"CHARACTER_CARD"}),
    office           = snap_point( 25.0, -6.0,  90, {"OFFICE_CARD"}),
    office_discard   = snap_point( 25.0, -9.0,  90, {"OFFICE_CARD"}),
  },
}

function snap_point_manager.recreate_all_snap_points()
  -- Will delete any other snap points already created
  local snaps = {}

  table.insert(snaps, SHARED.office_game_board)
  table.insert(snaps, SHARED.basement_game_board)

  table.insert(snaps, SHARED.encounters)
  table.insert(snaps, SHARED.encounters_discard)

  table.insert(snaps, SHARED.dark_web)
  table.insert(snaps, SHARED.dark_web_archives)

  table.insert(snaps, SHARED.virus_one)
  table.insert(snaps, SHARED.virus_two)
  table.insert(snaps, SHARED.virus_three)
  table.insert(snaps, SHARED.virus_four)
  table.insert(snaps, SHARED.virus_five)
  table.insert(snaps, SHARED.virus_six)

  for _, p in pairs(PLAYERS) do
    table.insert(snaps, p.character_card)
    table.insert(snaps, p.basement)
    table.insert(snaps, p.basement_discard)
    table.insert(snaps, p.office)
    table.insert(snaps, p.office_discard)
  end

  Global.setSnapPoints(snaps)
end

return snap_point_manager
