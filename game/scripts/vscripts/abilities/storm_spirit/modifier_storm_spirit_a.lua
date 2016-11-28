modifier_storm_spirit_a = class({})

if IsServer() then
    function modifier_storm_spirit_a:OnCreated()
        local index = FX("particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), {
            cp0 = { ent = self:GetParent(), point = "attach_attack1" }
        })

        self:AddParticle(index, false, false, -1, false, false)
    end
end

function modifier_storm_spirit_a:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_storm_spirit_a:GetActivityTranslationModifiers()
    return "overload"
end
