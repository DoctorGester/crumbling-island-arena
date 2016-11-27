qop_r = class({})

LinkLuaModifier("modifier_qop_r", "abilities/qop/modifier_qop_r", LUA_MODIFIER_MOTION_NONE)

function qop_r:FindModifier(ability)
    local hero = self:GetCaster().hero

    for _, modifier in pairs(hero:GetUnit():FindAllModifiersByName("modifier_qop_r")) do
        if modifier:GetAbility() == ability then
            return modifier
        end
    end
end

function qop_r:HasCharges(ability)
    local modifier = self:FindModifier(ability)

    return modifier ~= nil
end

function qop_r:ExpendCharge(ability)
    local modifier = self:FindModifier(ability)

    if modifier then
        modifier:DecrementStackCount()

        if modifier:GetStackCount() <= 0 then
            modifier:Destroy()
        else
            ability:EndCooldown()
            ability:StartCooldown(0.5)
        end
        
        local hero = self:GetCaster().hero

        if hero:GetHealth() > 2 then
            hero:Damage(hero, 2)
        end
    end
end

function qop_r:AbilityUsed(ability)
    if self:HasCharges(ability) then
        self:ExpendCharge(ability)
    end
end

function qop_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_scream_of_pain_owner.vpcf", PATTACH_ABSORIGIN, hero:GetUnit())
    ParticleManager:ReleaseParticleIndex(particle)

    for _, name in pairs({ "qop_e", "qop_w", "qop_q",  }) do
        local ability = hero:FindAbility(name)

        hero:AddNewModifier(hero, ability, "modifier_qop_r", { duration = 6 }):SetStackCount(3)
    end

    hero:EmitSound("Arena.QOP.CastR")

    Timers:CreateTimer(0.5, function()
        hero:EmitSound("Arena.QOP.CastR.Voice")
    end)
end

function qop_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end