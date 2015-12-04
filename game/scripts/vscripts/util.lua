function WrapString(str)
    local result = {}
    result[str] = 0
    return result
end

function UnwrapString(table)
    for k, _ in pairs(table) do
        return k
    end
end

function GetIndex(list, element)
    for k, v in pairs(list) do
        if v == element then
            return k
        end
    end

    return nil
end

function Shuffle(table)
    local iterations = #table
    local j

    for i = iterations, 2, -1 do
        j = RandomInt(1, i)
        table[i], table[j] = table[j], table[i]
    end
end

function IsLeft(a, b, c)
     return ((b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)) > 0
end

function RelativeCCW(x1, y1, x2, y2, px, py)
    x2 = x2 - x1
    y2 = y2 - y1
    px = px - x1
    py = py - y1

    local ccw = px * y2 - py * x2

    if ccw == 0.0 then
        ccw = px * x2 + py * y2
        if (ccw > 0.0) then
            px = px - x2
            py = py - y2
            ccw = px * x2 + py * y2
            if ccw < 0.0 then
                ccw = 0.0
            end
        end
    end

    if ccw < 0.0 then
        return -1
    else
        if ccw > 0.0 then
            return 1
        else
            return 0
        end
    end
end

function SegmentsIntersect2(x1, y1, x2, y2, x3, y3, x4, y4)
    local t1 = RelativeCCW(x1, y1, x2, y2, x3, y3) * RelativeCCW(x1, y1, x2, y2, x4, y4)
    local t2 = RelativeCCW(x3, y3, x4, y4, x1, y1) * RelativeCCW(x3, y3, x4, y4, x2, y2)
    return t1 <= 0 and t2 <= 0
end

function SegmentsIntersect(x1, y1, x2, y2, x3, y3, x4, y4)
    local d = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)
    if d == 0 then return false end --lines are parallel or coincidental
    local t1 = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / d
    local t2 = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / d

    return t1 >= 0 and t1 <= 1 and t2 >= 0 and t2 <= 1
end

function ClosestPointToSegment(start, finish, point)
    local segment = finish - start
    local pointVector = point - start

    local normalized = segment:Normalized()
    local dot = pointVector:Dot(normalized)

    if dot <= 0 then
        return start
    end

    if dot >= segment:Length2D() then
        return finish
    end

    return start + (normalized * dot)
end

function SegmentCircleIntersection(start, finish, point, radius)
    local closest = ClosestPointToSegment(start, finish, point)
    local dist = point - closest

    return dist:Length2D() <= radius
end

-- max height, full distance, current distance
function ParabolaZ(h, d, x)
  return (4 * h / d) * (d - x) * (x / d)
end

function ParabolaZ2(y0, y1, h, d, x)
    return ((4 * h / d) * (d - x) + y1 - y0) * (x / d) + y0
end

function AddLevelOneAbility(hero, abilityName)
    hero:AddAbility(abilityName)

    local ability = hero:FindAbilityByName(abilityName)
    ability:SetLevel(1)
end

function ImmediateEffect(path, attach, owner, time)
    local id = ParticleManager:CreateParticle(path, attach, owner.unit or owner)

    Timers:CreateTimer(time or 3,
        function()
            ParticleManager:DestroyParticle(id, false)
            ParticleManager:ReleaseParticleIndex(id)
        end
    )

    return id
end

function ImmediateEffectPoint(path, attach, owner, point, time)
    local effect = ImmediateEffect(path, attach, owner, time)
    ParticleManager:SetParticleControl(effect, 0, point)
    return effect
end

function MoveCameraToUnit(playerId, unit)
    Timers:CreateTimer(
        function()
            PlayerResource:SetCameraTarget(playerId, unit)
            Timers:CreateTimer(0.1,
                function()
                    PlayerResource:SetCameraTarget(playerId, nil)
                end
            )
        end
    )
end

function KnockbackUnit(unit, origin, duration, distance, height, should_stun)
    local modifierKnockback = {
        center_x = origin.x,
        center_y = origin.y,
        center_z = origin.z,
        knockback_duration = duration,
        knockback_distance = distance,
        knockback_height = height,
        duration = duration,
    }
    if should_stun then
        modifierKnockback.should_stun = 1
    end
    unit = unit.unit or unit
    unit:AddNewModifier(unit, nil, "modifier_knockback", modifierKnockback)
end

function LoadDefaultHeroItems(hero, gameItems)
    local heroName = hero:GetName()
    local defaultSlots = {}
    local cosmeticItems = {}

    for _, item in pairs(gameItems) do
        local prefab = item.prefab
        local wearable = prefab == "wearable"
        local default = prefab == "default_item"

        if (wearable or default) and item.used_by_heroes[heroName] == 1 then
            local itemSlot = item.item_slot

            -- Valve did not include some item_slot definitions for weapons
            if itemSlot == nil then
                itemSlot = "weapon"
            end

            if item.model_player ~= nil then
                if default and itemSlot ~= nil then
                    defaultSlots[itemSlot] = item.model_player
                else
                    local itemModels = {}
                    itemModels[item.model_player] = true

                    if item.visuals ~= nil then
                        local styles = item.visuals.styles

                        if styles ~= nil then
                            for _, style in pairs(styles) do
                                if style.model_player ~= nil then
                                    itemModels[style.model_player] = true
                                end
                            end
                        end
                    end

                    cosmeticItems[#cosmeticItems + 1] = { slot = itemSlot, models = itemModels }
                end
            end
        end
    end

    DeepPrintTable(defaultSlots)

    local children = hero:GetChildren()

    for _, child in pairs(children) do
        if child:GetClassname() == "dota_item_wearable" then
            for _, item in pairs(cosmeticItems) do
                if item.models[child:GetModelName()] then
                    child:SetModel(defaultSlots[item.slot])
                end
            end
        end
    end

    return hero
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end