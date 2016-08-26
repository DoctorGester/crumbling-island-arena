modifier_jugger_r = class({})

function modifier_jugger_r:GetStatusEffectName()
    return "particles/status_fx/status_effect_omnislash.vpcf"
end

function modifier_jugger_r:StatusEffectPriority()
    return 10
end

if IsServer() then
    function modifier_jugger_r:OnDestroy()
        self:GetParent():StopSound("Arena.Jugger.CastR")
    end
end