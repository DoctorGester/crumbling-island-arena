modifier_timber_r_target = class({})
local self = modifier_timber_r_target

if IsServer() then
    function self:OnCreated()
        self:CreateParticle()
        self:StartIntervalThink(1.0)
    end

    function self:OnIntervalThink()
        self:CreateParticle()

        local parent = self:GetParent():GetParentEntity()
        local caster = self:GetCaster():GetParentEntity()
        local blocked = parent:AllowAbilityEffect(caster, self:GetAbility()) == false
        local mod = parent:FindModifier("modifier_timber_r_slow")

        if not blocked then
            if not mod then
                parent:AddNewModifier(caster, ability, "modifier_timber_r_slow", { duration = 1.5 })
            else
                mod:SetStackCount(math.min(mod:GetStackCount() + 1, 3))
                mod:ForceRefresh()
            end
        end

        FX("particles/timber_r/timber_r_hit.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster(), {
            cp0 = self:GetCaster():GetAbsOrigin() + Vector(0, 0, 100),
            cp1 = { ent = self:GetParent(), point = "attach_hitloc" },
            release = true
        })
        self:GetParent():EmitSound("Arena.Timber.HitR")
    end

    function self:CreateParticle()
        local index = FX("particles/timber_r/timber_r_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {})
        self:AddParticle(index, false, false, -1, false, false)
    end
end

function self:IsDebuff()
    return true
end