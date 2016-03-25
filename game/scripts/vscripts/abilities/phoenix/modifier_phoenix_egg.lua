modifier_phoenix_egg = class({})

function modifier_phoenix_egg:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_DISABLE_TURNING
    }

    return funcs
end

function modifier_phoenix_egg:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
 
    return state
end

if IsServer() then
    function modifier_phoenix_egg:OnCreated()
        local u = self:GetParent()
        local p = u:GetOrigin()
        Timers:CreateTimer(.066,
            function()
                local index = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf", PATTACH_POINT_FOLLOW, u)
                ParticleManager:SetParticleControlEnt(index, 0, u, PATTACH_POINT_FOLLOW, "attach_hitloc", p, true)
                ParticleManager:SetParticleControlEnt(index, 1, u, PATTACH_POINT_FOLLOW, "attach_hitloc", p, true)
                ParticleManager:SetParticleControlEnt(index, 3, u, PATTACH_POINT_FOLLOW, "attach_hitloc", p, true)
                self:AddParticle(index, false, false, -1, false, false)
            end
        )

        u:EmitSound("Arena.Phoenix.StartP")
        u:EmitSound("Arena.Phoenix.LoopP")
    end

    function modifier_phoenix_egg:OnDestroy()
        local unit = self:GetParent()

        unit:StopSound("Arena.Phoenix.LoopP")
        unit:EmitSound("Arena.Phoenix.EndP")

        -- Can't start a new animation earlier
        Timers:CreateTimer(.066,
            function()
                StartAnimation(unit, { duration = 1.0, activity = ACT_DOTA_INTRO })

                ImmediateEffect("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_POINT_FOLLOW, unit)
            end
        )
    end
end

function modifier_phoenix_egg:GetModifierDisableTurning()
    return 1
end

function modifier_phoenix_egg:GetTexture()
    return "phoenix_supernova"
end

function modifier_phoenix_egg:GetModifierModelChange()
    return "models/heroes/phoenix/phoenix_egg.vmdl"
end

function modifier_phoenix_egg:GetOverrideAnimation()
    return ACT_DOTA_IDLE
end

function modifier_phoenix_egg:Airborne()
    return true
end