modifier_sk_e = class({})

function modifier_sk_e:OnCreated()
    if IsServer() then
        self:GetParent():AddNoDraw()
        self:GetParent().hero:SetInvulnerable(true)
    end
end

function modifier_sk_e:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveNoDraw()

        local hero = self:GetParent().hero
        local position = hero:GetPos()

        local effect = ImmediateEffect("particles/units/heroes/hero_sandking/sandking_burrowstrike_eruption.vpcf", PATTACH_POINT, hero)
        ParticleManager:SetParticleControl(effect, 0, position)
        ParticleManager:SetParticleControl(effect, 1, position)

        hero:SetInvulnerable(false)
        hero:EmitSound("Arena.SK.EndE")
        StartAnimation(self:GetParent(), { duration = 0.5, activity = ACT_DOTA_SAND_KING_BURROW_OUT, translate = "sandking_rubyspire_burrowstrike"})
    end
end

function modifier_sk_e:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end