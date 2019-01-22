modifier_timber_r = class({})
self = modifier_timber_r

function self:CheckState()
    local state = {
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }

    return state
end

function self:GetEffectName()
    return "particles/units/heroes/hero_disruptor/disruptor_static_storm.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
    function self:OnCreated()
        local index = FX("particles/aoe_marker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {
            cp1 = Vector(400, 1, 1),
            cp2 = Vector(201, 201, 0),
            cp3 = Vector(60, 0, 0)
        })

        local parent = self:GetParent()

        self:AddParticle(index, false, false, -1, false, false)

        index = FX("particles/units/heroes/hero_disruptor/disruptor_static_storm.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {
            cp1 = Vector(400, 1, 1)
        })

        self:AddParticle(index, false, false, -1, false, false)
    end
end