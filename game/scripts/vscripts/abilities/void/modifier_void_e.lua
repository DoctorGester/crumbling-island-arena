modifier_void_e = class({})
local self = modifier_void_e

if IsServer() then
    function self:OnCreated()
        local hero = self:GetParent():GetParentEntity()

        self.particle = FX("particles/econ/items/faceless_void/faceless_void_jewel_of_aeons/fv_time_walk_jewel.vpcf", PATTACH_ABSORIGIN, hero, {
            cp0 = { ent = self:GetParent(), point = "attach_hitloc" },
            --cp3 = { ent = self:GetParent(), point = "attach_hitloc" },
            --release = true
        })
    end

    function self:OnDestroy()
        local hero = self:GetParent():GetParentEntity()

        --Timers:CreateTimer(0.3, function()
            ParticleManager:DestroyParticle(self.particle, false)
            ParticleManager:ReleaseParticleIndex(self.particle)
        --end)

        hero:Animate(ACT_DOTA_CAST_ABILITY_1_END, 2.5)

        --hero:SwapAbilities("void_e_sub", "void_e")
        --hero:FindAbility("rubick_q"):StartCooldown(hero:FindAbility("rubick_q"):GetCooldown(1))
    end
end

function self:IsHidden()
    return true
end

function self:Airborne()
    return true
end

function self:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end