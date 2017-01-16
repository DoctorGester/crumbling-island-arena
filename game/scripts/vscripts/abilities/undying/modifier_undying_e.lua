modifier_undying_e = class({})
self = modifier_undying_e

function self:CheckState()
    local state = {
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }

    return state
end

function self:GetEffectName()
    return "particles/units/heroes/hero_undying/undying_tombstone.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
    function self:OnCreated()
        local index = FX("particles/aoe_marker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {
            cp1 = Vector(550, 1, 1),
            cp2 = Vector(0, 255, 74),
            cp3 = Vector(60, 0, 0)
        })

        self:AddParticle(index, false, false, -1, false, false)

        index = FX("particles/units/heroes/hero_undying/undying_fg_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {
            cp1 = Vector(550, 1, 1),
        })

        self:AddParticle(index, false, false, -1, false, false)
    end
end