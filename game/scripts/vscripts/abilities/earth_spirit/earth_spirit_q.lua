earth_spirit_q = class({})

require('abilities/earth_spirit/earth_spirit_remnant')
LinkLuaModifier("modifier_earth_spirit_stand", "abilities/earth_spirit/modifier_earth_spirit_stand", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_q:OnSpellStart()
    local caster = self:GetCaster()
    local cursor = self:GetCursorPosition()

    local particle = ImmediateEffect("particles/units/heroes/hero_earth_spirit/espirit_magnetize_target.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, cursor)

    local facing = cursor - caster:GetAbsOrigin()
    local down = Vector(0, 0, -10000)
    local unit = CreateUnitByName(caster:GetName(), down, false, nil, nil, caster:GetTeamNumber())
    facing.z = 0
    unit:AddNewModifier(unit, nil, "modifier_earth_spirit_remnant", {})
    unit:SetForwardVector(facing)
    unit:SetAbsOrigin(down)

    StartAnimation(unit, {duration=1, activity=ACT_DOTA_VICTORY, rate=10})

    Timers:CreateTimer(0.7,
        function()
            FreezeAnimation(unit)

            local remnant = EarthSpiritRemnant(caster.hero)
            remnant:SetPos(Vector(cursor.x, cursor.y, cursor.z + 600))
            remnant:CreateCounter()
            remnant:SetUnit(unit, true)

            caster.hero:AddRemnant(remnant)
            Spells:AddDynamicEntity(remnant)

            EmitSoundOnLocationWithCaster(cursor, "Hero_EarthSpirit.StoneRemnant.Impact", caster)
        end
    )
end