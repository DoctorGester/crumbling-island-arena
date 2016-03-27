earth_spirit_q = class({})

require('abilities/earth_spirit/earth_spirit_remnant')
LinkLuaModifier("modifier_earth_spirit_stand", "abilities/earth_spirit/modifier_earth_spirit_stand", LUA_MODIFIER_MOTION_NONE)

-- Bugged with script_reload
function earth_spirit_q:GetCastRange(location, target)
    if self:GetCaster():HasModifier("modifier_earth_spirit_stand") then
        return 0
    end

    return 1000
end

function earth_spirit_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local cursor = self:GetCursorPosition()
    local dir = cursor - hero:GetPos()
    local castRange = 1000

    if dir:Length2D() > castRange then
        cursor = hero:GetPos() + dir:Normalized() * castRange
    end

    local particle = ImmediateEffect("particles/units/heroes/hero_earth_spirit/espirit_magnetize_target.vpcf", PATTACH_CUSTOMORIGIN, hero)
    ParticleManager:SetParticleControl(particle, 0, cursor)

    local down = Vector(0, 0, 10000)
    local unit = CreateUnitByName(hero:GetName(), down, false, nil, nil, hero:GetUnit():GetTeamNumber())

    unit:AddNewModifier(unit, nil, "modifier_earth_spirit_remnant", {})
    unit:SetForwardVector(dir * Vector(1, 1, 0))
    unit:SetAbsOrigin(down)

    StartAnimation(unit, {duration=1, activity=ACT_DOTA_VICTORY, rate=10})

    Timers:CreateTimer(0.7,
        function()
            FreezeAnimation(unit)

            local remnant = EarthSpiritRemnant(hero.round, hero)
            remnant:CreateCounter()
            remnant:SetUnit(unit, true)
            remnant:SetPos(cursor + Vector(0, 0, 600))
            remnant:Activate()

            hero:AddRemnant(remnant)
        end
    )
end