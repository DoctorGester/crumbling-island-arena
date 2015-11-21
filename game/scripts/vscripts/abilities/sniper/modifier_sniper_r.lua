modifier_sniper_r = class({})

function modifier_sniper_r:OnCreated()
    if IsServer() then
        self.wasInvisible = false
    end
end

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

        for _, target in pairs(Spells:GetValidTargets()) do
            local distance = (target:GetPos() - hero:GetPos()):Length2D()

            if target ~= hero and distance <= 400 then
                invisible = false
                break
            end
        end

        state[MODIFIER_STATE_INVISIBLE] = invisible
    end

    return state
end

function modifier_sniper_r:OnDestroy()
    if IsServer() then
        self:GetParent().hero:RemoveModifier("modifier_persistent_invisibility")
    end
end

function modifier_sniper_r:GetModifierMoveSpeedOverride(params)
    return 210
end

function modifier_sniper_r:GetModifierInvisibilityLevel(params)
    if IsClient() then
        return self:GetStackCount()
    end

    local level = 0

    if self:CheckState()[MODIFIER_STATE_INVISIBLE] then
        level = 1
    end

    if IsServer() then
        self:SetStackCount(level)
    end

    return level
end

function modifier_sniper_r:GetEffectName()
    return "particles/sniper_r/sniper_r.vpcf"
end

function modifier_sniper_r:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end