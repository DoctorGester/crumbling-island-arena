modifier_void_q_root = class({})

if IsServer() then
    function modifier_void_q_root:OnCreated()
        local hero = self:GetParent():GetParentEntity()
        hero:EmitSound("Arena.Void.ProcQ")

        self.p1 = FX(hero:GetMappedParticle("particles/units/heroes/hero_dark_willow/dark_willow_bramble.vpcf"), PATTACH_POINT_FOLLOW, hero, {
            cp0 = { ent = self:GetParent() },
            cp3 = { ent = self:GetParent() }
        })
    end

    function modifier_void_q_root:OnDestroy()
        local hero = self:GetParent():GetParentEntity()
        hero:EmitSound("Arena.Void.EndQ")
        
        ParticleManager:DestroyParticle(self.p1, false)
        ParticleManager:ReleaseParticleIndex(self.p1)
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