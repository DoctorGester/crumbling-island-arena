wk_q = class({})

LinkLuaModifier("modifier_wk_q", "abilities/wk/modifier_wk_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wk_skeleton", "abilities/wk/modifier_wk_skeleton", LUA_MODIFIER_MOTION_NONE)

require('abilities/wk/entity_wk_skeleton')

function wk_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = (target - hero:GetPos()):Normalized()
    local rotated = Vector(direction.y, -direction.x)

    for i = -2, 2 do
        for j = 1, 3 do
            local position = hero:GetPos() + direction * 100 * j + rotated * i * 64
            WKSkeleton(hero.round, hero, self, position, direction):Activate()

            local particle = ParticleManager:CreateParticle("particles/neutral_fx/skeleton_spawn_c.vpcf", PATTACH_ABSORIGIN, hero:GetUnit())
            ParticleManager:SetParticleControl(particle, 0, position)
            ParticleManager:ReleaseParticleIndex(particle)
        end
    end

    ScreenShake(hero:GetPos(), 5, 150, 0.25, 2000, 0, true)
    hero:EmitSound("Arena.WK.CastQ")
end

function wk_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function wk_q:GetPlaybackRateOverride()
    return 2.0
end