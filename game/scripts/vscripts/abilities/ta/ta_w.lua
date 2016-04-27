ta_w = class({})
LinkLuaModifier("modifier_ta_w", "abilities/ta/modifier_ta_w", LUA_MODIFIER_MOTION_NONE)

function ta_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local pos = hero:GetPos()

    local target = self:GetCursorPosition()
    local castDirection = (target - hero:GetPos()):Normalized()

    if castDirection:Length2D() == 0 then
        castDirection = hero:GetFacing()
    end

    local effect = ImmediateEffect("particles/ta_w/ta_w.vpcf", PATTACH_CUSTOMORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 0, hero:GetPos() + Vector(0, 0, 32))
    ParticleManager:SetParticleControl(effect, 1, pos + castDirection * 350 + Vector(0, 0, 32))

    hero:AreaEffect({
        onlyHeroes = true,
        filter = Filters.Cone(pos, 500, castDirection, math.pi / 2),
        modifier = { name = "modifier_ta_w", duration = 3.5, ability = self }
    })

    hero:EmitSound("Arena.TA.CastW")
end

function ta_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end