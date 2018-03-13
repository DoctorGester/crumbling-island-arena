modifier_sniper_r = class({})

local alreadyCheckedMyStateThankYou = false

function modifier_sniper_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }

    return funcs
end

function modifier_sniper_r:CheckState()
    local state = {
    }

    if IsServer() then
        local hero = self:GetParent().hero
        local invisible = true

        for _, target in pairs(hero.round.spells:GetHeroTargets()) do
            local distance = (target:GetPos() - hero:GetPos()):Length2D()

            if target.owner.team ~= hero.owner.team and distance <= 400 then
                invisible = false
                break
            end
        end

        state[MODIFIER_STATE_INVISIBLE] = invisible

        if not alreadyCheckedMyStateThankYou then
            alreadyCheckedMyStateThankYou = true
            if invisible then
                self:SetStackCount(1)
            else
                self:SetStackCount(0)
            end
            alreadyCheckedMyStateThankYou = false
        end
    end

    return state
end

function modifier_sniper_r:GetModifierMoveSpeedOverride(params)
    return 210
end

function modifier_sniper_r:GetModifierInvisibilityLevel(params)
    return self:GetStackCount()
end

function modifier_sniper_r:GetEffectName()
    return "particles/sniper_r/sniper_r.vpcf"
end

function modifier_sniper_r:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end