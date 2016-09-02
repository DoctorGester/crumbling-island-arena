CM = class({
    icePath = nil
}, {}, Hero)

LinkLuaModifier("modifier_cm_frozen", "abilities/cm/modifier_cm_frozen", LUA_MODIFIER_MOTION_NONE)

function CM:IsFrozen(target)
    return target:FindModifier("modifier_cm_frozen") or target:FindModifier("modifier_cm_r_slow")
end

function CM:Freeze(target, ability)
    target:AddNewModifier(self, ability, "modifier_cm_frozen", { duration = 1.65 })
end

function CM:SetIcePath(icePath)
    self.icePath = icePath
end

function CM:GetIcePath()
    return self.icePath
end

function CM:Remove()
    self:StopSound("Arena.CM.LoopE")
    self:StopSound("Arena.CM.LoopR")

    getbase(CM).Remove(self)
end