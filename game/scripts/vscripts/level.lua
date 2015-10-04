SECOND_STAGE_OBSTRUCTOR = "Layer2Obstructor"
THIRD_STAGE_OBSTRUCTOR = "Layer3Obstructor"

if Level == nil then
	Level = class({})
end

function Level:EnableObstructors(obstructors, enable)
	for _, obstructor in pairs(obstructors) do
		obstructor:SetEnabled(enable, true)
	end
end

function Level:SwapLayers(old, new)
	DoEntFire(new, "ShowWorldLayerAndSpawnEntities", "", 0.0, nil, nil)
	DoEntFire(old, "HideWorldLayerAndDestroyEntities", "", 0.0, nil, nil)
end

function Level:TestOutOfMap(hero, stage)
	if stage == 1 then
		return
	end

	local name = SECOND_STAGE_OBSTRUCTOR

	if stage == 3 then
		name = THIRD_STAGE_OBSTRUCTOR
	end

	local start = hero:GetPos()
	local obstructions = Entities:FindAllByName(name)
	local center = Entities:FindByName(nil, "map_center"):GetAbsOrigin()

	for _, obstruction in pairs(obstructions) do
		local o = obstruction:GetCenter()
		local size = 64
		local top = {x1 = o.x - size, y1 = o.y + size, x2 = o.x + size, y2 = o.y + size}
		local left = {x1 = o.x - size, y1 = o.y - size, x2 = o.x - size, y2 = o.y + size}
		local right = {x1 = o.x + size, y1 = o.y - size, x2 = o.x + size, y2 = o.y + size}
		local bottom = {x1 = o.x - size, y1 = o.y - size, x2 = o.x + size, y2 = o.y - size}

		local sides = { top, left, right, bottom }

		for _, side in pairs(sides) do
			local result = SegmentsIntersect2(start.x, start.y, center.x, center.y, side.x1, side.y1, side.x2, side.y2)
			if result then
				return true
			end
		end
	end

	return false
end
