modifier_dusa_r_target = class({})
local self = modifier_dusa_r_target

if IsServer() then
    function self:OnCreated()
        local index = FX("particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), {
            cp0 = { point = "attach_hitloc", ent = self:GetParent() },
            cp1 = { ent = self:GetCaster() }
        })

        self:AddParticle(index, false, false, -1, false, false)

        index = FX("particles/units/heroes/hero_medusa/medusa_stone_gaze_facing.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), {
            cp0 = { point = "attach_hitloc", ent = self:GetParent() },
            cp1 = { ent = self:GetCaster() }
        })

        self:AddParticle(index, false, false, -1, false, false)
        self:StartIntervalThink(1.0)
        self:GetParent():GetParentEntity():EmitSound("Arena.Medusa.StartR")
    end

    function self:OnIntervalThink()
        self:GetParent():GetParentEntity():EmitSound("Arena.Medusa.EndR")
        self:GetParent():GetParentEntity():AddNewModifier(self:GetCaster():GetParentEntity(), self:GetAbility(), "modifier_dusa_r", { duration = 1.7 })
    end
end

function self:IsDebuff()
    return true
end