modifier_sniper_r = class({})

function modifier_sniper_r:OnCreated()
    if IsServer() then
        self.wasInvisible = false
    end
end

function modifier_sniper_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
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

        if not self.wasInvisible and invisible then
            self.wasInvisible = invisible
            hero:AddNewModifier(hero, self:GetAbility(), "modifier_invis_fade", { duration = 0, invis_kind = "modifier_persistent_invisibility" })
        end

        if self.wasInvisible and not invisible then
            self.wasInvisible = invisible
            hero:RemoveModifier("modifier_persistent_invisibility")
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