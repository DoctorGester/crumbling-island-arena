modifier_ld_root = class({})

if IsServer() then
    function modifier_ld_root:OnCreated()
        self:GetParent():EmitSound("Arena.LD.HitRoot")
    end
end

function modifier_ld_root:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

function modifier_ld_root:IsDebuff()
    return true
end

function modifier_ld_root:GetEffectName()
    return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
end

function modifier_ld_root:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
