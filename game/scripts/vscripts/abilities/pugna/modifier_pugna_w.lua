modifier_pugna_w = class({})

if IsServer() then
    function modifier_pugna_w:OnCreated(keys)
        self:StartIntervalThink(0.1)

        self.effect = ParticleManager:CreateParticle("particles/pugna_w/pugna_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.effect, 2, self:GetCaster().hero:GetTrapColor())
        self:AddParticle(self.effect, false, false, 1, false, false)
    end
end

function modifier_pugna_w:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true
    }

    return state
end

function modifier_pugna_w:OnIntervalThink()
    local hero = self:GetCaster().hero
    local trap = self:GetParent()

    ParticleManager:SetParticleControl(self.effect, 2, hero:GetTrapColor())

    if self:GetElapsedTime() >= 1.5 then
        if not self.rune then
            self.rune = ParticleManager:CreateParticle("particles/pugna_w/pugna_w_rune.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            self:AddParticle(self.rune, false, false, 1, false, false)
            self:GetParent().entity.collisionType = COLLISION_TYPE_INFLICTOR
        end

        ParticleManager:SetParticleControl(self.rune, 2, hero:GetTrapColor())
    end
end
