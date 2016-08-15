modifier_undying_e_target = class({})
local self = modifier_undying_e_target

if IsServer() then
    function self:OnCreated()
        self:CreateParticle()
        self:StartIntervalThink(2.5)
    end

    function self:OnIntervalThink()
        self:CreateParticle()

        self:GetParent():GetParentEntity():Damage(self:GetCaster():GetParentEntity())
        FX("particles/undying_e/undying_e_hit.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster(), {
            cp0 = self:GetCaster():GetAbsOrigin() + Vector(0, 0, 200),
            cp1 = { ent = self:GetParent(), point = "attach_hitloc" },
            release = true
        })
        self:GetParent():EmitSound("Arena.Undying.HitE")
    end

    function self:CreateParticle()
        local index = FX("particles/undying_e/undying_e_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {})
        self:AddParticle(index, false, false, -1, false, false)
    end
end

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function self:IsDebuff()
    return true
end

function self:GetModifierMoveSpeedBonus_Percentage(params)
    return -15
end