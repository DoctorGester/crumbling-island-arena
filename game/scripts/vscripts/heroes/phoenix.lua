EGG_MODIFIER = "modifier_phoenix_egg"

Phoenix = class({}, {}, Hero)

if IsServer() then
    LinkLuaModifier(EGG_MODIFIER, "abilities/phoenix/modifier_phoenix_egg", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_phoenix_egg_tooltip", "abilities/phoenix/modifier_phoenix_egg_tooltip", LUA_MODIFIER_MOTION_NONE)
end

function Phoenix:SetUnit(unit)
    self.__base__.SetUnit(self, unit)

    self:AddNewModifier(self, unit:FindAbilityByName("phoenix_w"), "modifier_charges",
        {
            max_count = 2,
            replenish_time = 6
        }
    )
    self:AddNewModifier(self, nil, "modifier_phoenix_egg_tooltip", {})
end

function Phoenix:Damage(source)
    if source == self then
        Hero.Damage(self, source)
        return
    end

    if not self:FindModifier(EGG_MODIFIER) then
        if self:GetHealth() == 1 then
            self.unit:Interrupt()
            self:AddNewModifier(self, nil, EGG_MODIFIER, { duration = 5 })
            return
        end
    end

    Hero.Damage(self, source)
end

function Phoenix:CastFilterResultLocation()
    return (self:GetCaster():HasModifier(EGG_MODIFIER) and UF_FAIL_CUSTOM or UF_SUCCESS)
end

function Phoenix:GetCustomCastErrorLocation()
    return (self:GetCaster():HasModifier(EGG_MODIFIER) and "#dota_hud_error_cant_cast_in_egg" or "")
end
