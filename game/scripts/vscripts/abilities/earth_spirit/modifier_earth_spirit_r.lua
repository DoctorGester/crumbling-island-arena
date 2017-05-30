---@type CDOTA_Modifier_Lua
modifier_earth_spirit_r = class({})

if IsServer() then
    function modifier_earth_spirit_r:OnCreated()
        self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_2_ES_ROLL)
        
        local index = FX("particles/earth_spirit_e/earth_spirit_e.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {
            cp3 = { ent = self:GetParent(), point = "attach_hitloc" },
            cp10 = Vector(2, 0, 0),
            release = false
        })
        
        self:AddParticle(index, false, false, 0, false, false)
    end

    function modifier_earth_spirit_r:OnDestroy()
        self:GetParent():FadeGesture(ACT_DOTA_CAST_ABILITY_2_ES_ROLL)
        self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_2_ES_ROLL_END)
    end
end

function modifier_earth_spirit_r:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_earth_spirit_r:IsStunDebuff()
    return true
end

function modifier_earth_spirit_r:AllowAbilityEffect(source)
    return false
end

function modifier_earth_spirit_r:OnDamageReceived()
    return false
end

function modifier_earth_spirit_r:OnDamageReceivedPriority()
    return 1
end