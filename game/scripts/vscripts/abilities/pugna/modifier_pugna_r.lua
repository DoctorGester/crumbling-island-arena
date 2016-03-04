modifier_pugna_r = class({})

if IsServer() then
    function modifier_pugna_r:OnCreated(kv)
        local parent = self:GetParent()
        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(index, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetOrigin(), true)
        self:AddParticle(index, false, false, -1, false, false)

        parent:EmitSound("Arena.Pugna.CastR")
        parent:EmitSound("Arena.Pugna.LoopR")
    end

    function modifier_pugna_r:OnDestroy()
        local parent = self:GetParent()
        parent:StopSound("Arena.Pugna.LoopR")
        parent:EmitSound("Arena.Pugna.EndR")
    end
end

function modifier_pugna_r:CheckState()
    local state = {
        [MODIFIER_STATE_SILENCED] = false
    }

    return state
end

function modifier_pugna_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE 
    }

    return funcs
end

function modifier_pugna_r:GetModifierMoveSpeed_Absolute()
    return self:GetParent():GetBaseMoveSpeed()
end