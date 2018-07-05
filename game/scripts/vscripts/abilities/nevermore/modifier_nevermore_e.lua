modifier_nevermore_e = class({})

if IsServer() then
    function modifier_nevermore_e:OnCreated()
        local index = FX("particles/nevermore_e/nevermore_e.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {
            release = false
        })

        self:AddParticle(index, false, false, 0, false, false)
    end
end

function modifier_nevermore_e:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_nevermore_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_nevermore_e:GetActivityTranslationModifiers()
    return "forcestaff_friendly"
end

function modifier_nevermore_e:Airborne()
    return true
end