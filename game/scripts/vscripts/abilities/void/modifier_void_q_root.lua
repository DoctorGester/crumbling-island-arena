modifier_void_q_root = class({})

if IsServer() then
    function modifier_void_q_root:OnCreated()
        local hero = self:GetParent():GetParentEntity()
        hero:EmitSound("Arena.Void.ProcQ")

        self.particle = FX(hero:GetMappedParticle("particles/units/heroes/hero_dark_willow/dark_willow_bramble.vpcf"), PATTACH_POINT_FOLLOW, hero, {
            cp0 = { ent = hero },
            cp3 = { ent = hero }
        })
    end

    function modifier_void_q_root:OnDestroy()
        self:GetParent():GetParentEntity():EmitSound("Arena.Void.EndQ")

        DFX(self.particle)
    end
end

function modifier_void_q_root:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

function modifier_void_q_root:IsDebuff()
    return true
end