Timber = class({}, {}, Hero)

LinkLuaModifier("modifier_timber_heal_to_shield", "abilities/timber/modifier_timber_heal_to_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_timber_r_charges", "abilities/timber/modifier_timber_r_charges", LUA_MODIFIER_MOTION_NONE)

function Timber:SetOwner(owner)
    getbase(Timber).SetOwner(self, owner)

    self:AddNewModifier(self, nil, "modifier_timber_heal_to_shield", {})
    self:AddNewModifier(self, nil, "modifier_timber_r_charges", {})
end