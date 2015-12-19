SECOND_STAGE_OBSTRUCTOR = "Layer2Obstructor"
THIRD_STAGE_OBSTRUCTOR = "Layer3Obstructor"

if Level == nil then
    Level = class({})
end

function Level:constructor()
    --[[SpawnEntityFromTableSynchronous("prop_dynamic", {
        origin = Vector(-450, -770, 128),
        angles = Vector(0, 270, 0),
        scales = Vector(14, 14, 14),
        model = "fbx1.vmdl"
    })]]
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

function Level:TestOutOfMap(entity, stage)
    if stage == 1 then
        return
    end

    local name = SECOND_STAGE_OBSTRUCTOR

    if stage == 3 then
        name = THIRD_STAGE_OBSTRUCTOR
    end

    local start = entity:GetPos()
    local obstructions = Entities:FindAllByName(name)
    local center = Entities:FindByName(nil, "map_center"):GetAbsOrigin()

    for _, obstruction in ipairs(obstructions) do
        local o = obstruction:GetCenter()
        local size = 64
        local top = {x1 = o.x - size, y1 = o.y + size, x2 = o.x + size, y2 = o.y + size}
        local left = {x1 = o.x - size, y1 = o.y - size, x2 = o.x - size, y2 = o.y + size}
        local right = {x1 = o.x + size, y1 = o.y - size, x2 = o.x + size, y2 = o.y + size}
        local bottom = {x1 = o.x - size, y1 = o.y - size, x2 = o.x + size, y2 = o.y - size}

        local sides = { top, left, right, bottom }

        for _, side in ipairs(sides) do
            local result = SegmentsIntersect2(start.x, start.y, center.x, center.y, side.x1, side.y1, side.x2, side.y2)
            if result then
                return true
            end
        end
    end

    return false
end

function Level:PlayDestructionEffect(stage)
    local name = SECOND_STAGE_OBSTRUCTOR

    if stage == 3 then
        name = THIRD_STAGE_OBSTRUCTOR
    end

    local obstructions = Entities:FindAllByName(name)
    local center = Entities:FindByName(nil, "map_center"):GetAbsOrigin()

    for i, obstruction in ipairs(obstructions) do
        if i % 2 == 0 then
            local pos = obstruction:GetCenter()

            local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_avalanche.vpcf", PATTACH_ABSORIGIN, GameRules.GameMode.Players[0].fow)
            ParticleManager:SetParticleControl(effect, 0, pos)
            ParticleManager:SetParticleControl(effect, 1, Vector(100, 100, 100))

            Timers:CreateTimer(3,
                function()
                    ParticleManager:DestroyParticle(effect, false)
                    ParticleManager:ReleaseParticleIndex(effect)
                end
            )
        end
    end
end