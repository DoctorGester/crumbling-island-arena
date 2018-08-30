Void = class({}, {}, Hero)

LinkLuaModifier("modifier_void", "abilities/void/modifier_void", LUA_MODIFIER_MOTION_NONE)

function Void:SetOwner(owner)
    getbase(Void).SetOwner(self, owner)

    self:AddNewModifier(self, nil, "modifier_void", {})
end