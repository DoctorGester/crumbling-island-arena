modifier_slark_e_leash = class({})

if IsServer() then
    function modifier_slark_e_leash:OnCreated()
        local startPos = self:GetCaster():GetAbsOrigin()

        self.startPos = startPos

        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_ground.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(index, 3, startPos)

        self:AddParticle(index, false, false, -1, false, false)

        index = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_leash.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(index, 3, startPos)
        ParticleManager:SetParticleControlEnt(index, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

        self:AddParticle(index, false, false, -1, false, false)
        self:GetParent():EmitSound("Arena.Slark.LoopE")

        self:StartIntervalThink(1 / 30)
    end

    function modifier_slark_e_leash:GetModifierMoveSpeed_Limit()
        local dir = self:GetParent():GetAbsOrigin() - self.startPos

        if dir:Length2D() > 325 and dir:Normalized():Dot(self:GetParent():GetForwardVector()) > 0 then
            return 0.1
        end
    end

    function modifier_slark_e_leash:OnIntervalThink()
        local dir = self:GetParent():GetAbsOrigin() - self.startPos

        if dir:Length2D() > 375 then
            self:Destroy()
        end
    end

    function modifier_slark_e_leash:OnDestroy()
        self:GetParent():StopSound("Arena.Slark.LoopE")
    end
end

function modifier_slark_e_leash:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_LIMIT
    }

    return funcs
end

function modifier_slark_e_leash:GetOverrideAnimation(params)
    return ACT_DOTA_SLARK_POUNCE
end

function modifier_slark_e_leash:GetEffectName()
    return "particles/units/heroes/hero_slark/slark_pounce_trail.vpcf"
end