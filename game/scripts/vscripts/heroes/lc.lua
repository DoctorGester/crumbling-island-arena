LC = class({}, {}, Hero)

LinkLuaModifier("modifier_lc_q_animation", "abilities/lc/modifier_lc_q_animation", LUA_MODIFIER_MOTION_NONE)

function LC:SetUnit(unit)
    self.__base__.SetUnit(self, unit)

    self:AddNewModifier(self, nil, "modifier_lc_q_animation", {})
end

function LC:Damage(source)
    if source == self then
        Hero.Damage(self, source)
        return
    end

    local shield = self:FindModifier("modifier_lc_w_shield")

    if shield then
        local ability = shield:GetAbility()
        self:RemoveModifier("modifier_lc_w_shield")

        self:AddNewModifier(self, ability, "modifier_lc_w_speed", { duration = 4 })
        return
    end

    if self:FindModifier("modifier_lc_r") and self:GetHealth() == 1 then
        return
    end

    Hero.Damage(self, source)
end