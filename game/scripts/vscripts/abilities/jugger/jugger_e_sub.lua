jugger_e_sub = class({})

function jugger_e_sub:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local casterPos = hero:GetPos()
    local target = self:GetCursorPosition()

    local particle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/pw_blossom_sword/juggernaut_omni_slash_rope.vpcf", PATTACH_POINT, self:GetCaster())

    ParticleManager:SetParticleControl(particle, 2, hero:GetPos() + Vector(0, 0, 64))
    ParticleManager:SetParticleControl(particle, 3, target + Vector(0, 0, 64))
    ParticleManager:ReleaseParticleIndex(particle)

    GridNav:DestroyTreesAroundPoint(target, 128, true)
    hero:FindClearSpace(target, true)
    hero:EmitSound("Arena.Jugger.CastE2")
end

function jugger_e_sub:GetCastAnimation()
    return ACT_DOTA_SPAWN
end

function jugger_e_sub:GetPlaybackRateOverride()
    return 2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(jugger_e_sub)