jugger_q = class({})

LinkLuaModifier("modifier_jugger_q", "abilities/jugger/modifier_jugger_q", LUA_MODIFIER_MOTION_NONE)

function jugger_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local particle = ParticleManager:CreateParticle("particles/jugger_e/jugger_e.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, hero:GetPos() + Vector(0, 0, 64))
    ParticleManager:ReleaseParticleIndex(particle)

    hero:AddNewModifier(hero, self, "modifier_jugger_q", { duration = 2.5 })
    hero:EmitSound("Arena.Jugger.CastQ.Voice")
end

function jugger_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end