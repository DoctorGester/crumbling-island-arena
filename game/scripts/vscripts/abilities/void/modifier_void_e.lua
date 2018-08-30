modifier_void_e = class({})
local self = modifier_void_e

if IsServer() then
    function self:OnCreated()
        local hero = self:GetParent():GetParentEntity()
        local path = "particles/econ/items/faceless_void/faceless_void_jewel_of_aeons/fv_time_walk_jewel.vpcf"

        if hero:FindAbility("void_e_sub") == self:GetAbility() then
            path = "particles/void_e/void_e_alt_jewel.vpcf"
        end

        self.particle = FX(path, PATTACH_ABSORIGIN, hero, {
            cp0 = { ent = hero, point = "attach_hitloc" }
        })
    end

    function self:OnDestroy()
        DFX(self.particle)

        self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1_END, 2.5)
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