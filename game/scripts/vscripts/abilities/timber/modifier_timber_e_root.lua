modifier_timber_e_root = class({})
local self = modifier_timber_e_root

function self:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

function self:IsDebuff()
    return true
end

if IsServer() then
    function self:OnCreated()
        local hero = self:GetParent():GetParentEntity()

        self.p1 = FX(hero:GetMappedParticle("particles/timber_e/timber_e_root.vpcf"), PATTACH_POINT_FOLLOW, hero, {
            cp0 = { ent = self:GetParent() }
        })
    end

    function self:OnDestroy()
        local hero = self:GetParent():GetParentEntity()
        
        ParticleManager:DestroyParticle(self.p1, false)
        ParticleManager:ReleaseParticleIndex(self.p1)
    end
end
