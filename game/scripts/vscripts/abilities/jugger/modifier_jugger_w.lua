modifier_jugger_w = class({})

if IsServer() then
    function modifier_jugger_w:OnCreated()
        local unit = self:GetParent()
        ImmediateEffectPoint("particles/units/heroes/hero_juggernaut/juggernaut_healing_ward_eruption.vpcf", PATTACH_ABSORIGIN, unit, unit:GetAbsOrigin())
    end

    function modifier_jugger_w:OnDestroy()
        self:GetParent().hero:Destroy()
    end
end

function modifier_jugger_w:IsAura()
    return true
end

function modifier_jugger_w:GetAuraRadius()
    return 400
end

function modifier_jugger_w:GetAuraDuration()
    return 0.1
end

function modifier_jugger_w:GetModifierAura()
    return "modifier_jugger_w_target"
end

function modifier_jugger_w:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_jugger_w:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end