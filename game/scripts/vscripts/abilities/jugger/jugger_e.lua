jugger_e = class({})

LinkLuaModifier("modifier_jugger_e", "abilities/jugger/modifier_jugger_e", LUA_MODIFIER_MOTION_NONE)

function jugger_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local particle = ParticleManager:CreateParticle("particles/jugger_e/jugger_e.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, hero:GetPos() + Vector(0, 0, 64))
    ParticleManager:ReleaseParticleIndex(particle)

    hero:AddNewModifier(hero, self, "modifier_jugger_e", { duration = 1.8 })
    hero:SwapAbilities("jugger_e", "jugger_e_sub")
    hero:EmitSound("Arena.Jugger.CastE")
end

function jugger_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end