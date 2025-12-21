-- zone_manager.lua
-- All basic functions related to zones

local zone_manager = {}

function zone_manager.is_in_zone(args)
  local object = args.object
  local zone_guid = args.zone_guid

  for _, zone in ipairs(object:getZones()) do
    if zone:getGUID() == zone_guid then
      return true
    end
  end
  return false
end

function zone_manager.find_zone_by_name(args)
  local name = args.name

  for _, object in ipairs(getAllObjects() or {}) do
    if object:getName() == name then
      return object
    end
  end
  return nil
end

function zone_manager.get_zone_center_and_yaw(args)
  -- Yaw is the name for rotation in the y axis.
  -- x-rotation is called pitch, it tilts up/down
  -- y-rotation is called yaw, it turns left/right
  -- z-rotation is called roll, leaning left/right
  local zone_guid = args.zone_guid

  local object = getObjectFromGUID(zone_guid)
  local position = object:getPosition() + Vector(0, 2, 0)
  local rotation = object:getRotation()
  return position, rotation.y
end

function zone_manager.get_objects_in_zone(args)
  local zone_guid = args.zone_guid

  local zone = getObjectFromGUID(zone_guid)
  local objects_in_zone  = {}

  for _, object in ipairs(getAllObjects()) do
    if not object.locked then
      for _, object_zone in ipairs(object:getZones()) do
        if object_zone == zone then
          table.insert(objects_in_zone, object)
          break
        end
      end
    end
  end

  return objects_in_zone
end

return zone_manager
