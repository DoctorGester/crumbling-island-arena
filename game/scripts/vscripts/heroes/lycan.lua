Lycan = class({}, {}, Hero)

LinkLuaModifier("modifier_lycan_instinct", "abilities/lycan/modifier_lycan_instinct", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lycan_bleed", "abilities/lycan/modifier_lycan_bleed", LUA_MODIFIER_MOTION_NONE)

function Lycan:SetUnit(unit)
    self.__base__.SetUnit(self, unit)

    self:AddNewModifier(self, nil, "modifier_lycan_instinct")
end

function Lycan:IsTransformed()
    return self:FindModifier("modifier_lycan_r")
end

function Lycan:IsBleeding(target)
    return target:FindModifier("modifier_lycan_bleed")
end

function Lycan:MakeBleed(target, ability)
    target:AddNewModifier(self, ability, "modifier_lycan_bleed", { duration = 4 })

    local fear = target:FindModifier("modifier_lycan_e")

    if fear then
        fear.bleedingOccured = true
    end
end
