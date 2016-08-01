Lycan = class({}, {}, Hero)

LinkLuaModifier("modifier_lycan_instinct", "abilities/lycan/modifier_lycan_instinct", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lycan_bleed", "abilities/lycan/modifier_lycan_bleed", LUA_MODIFIER_MOTION_NONE)

function Lycan:SetUnit(unit)
    self.__base__.SetUnit(self, unit)

    self:AddNewModifier(self, nil, "modifier_lycan_instinct")
end

function Lycan:GetAwardSeason()
    return 0
end

function Lycan:SetOwner(owner)
    getbase(Lycan).SetOwner(self, owner)

    if self:IsAwardEnabled() then
        for _, part in pairs({ "armor", "belt", "weapon", "shoulder", "head" }) do
            self:AttachWearable("models/items/lycan/hunter_kings_"..part.."/hunter_kings_"..part..".vmdl")
        end
    else
        for _, part in pairs({ "armor", "belt", "blades", "fur", "head" }) do
            self:AttachWearable("models/heroes/lycan/lycan_"..part..".vmdl")
        end
    end
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
