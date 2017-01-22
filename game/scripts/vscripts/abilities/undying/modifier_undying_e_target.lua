modifier_undying_e_target = class({})
local self = modifier_undying_e_target

if IsServer() then
    function self:OnCreated()
        self:CreateParticle()
        self:StartIntervalThink(2.5)
    end

    function self:OnIntervalThink()
        self:CreateParticle()

        local parent = self:GetParent():GetParentEntity()
        local caster = self:GetCaster():GetParentEntity()
        local blocked = parent:AllowAbilityEffect(caster, self:GetAbility()) == false

        if not blocked then
            parent:Damage(caster, self:GetAbility():GetDamage())
        end

        FX("particles/undying_e/undying_e_hit.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster(), {
            cp0 = self:GetCaster():GetAbsOrigin() + Vector(0, 0, 200),
            cp1 = { ent = self:GetParent(), point = "attach_hitloc" },
            release = true
        })
        self:GetParent():EmitSound("Arena.Undying.HitE")
    end

    function self:CreateParticle()
        local index = FX("particles/undying_e/undying_e_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {})
        self:AddParticle(index, false, false, -1, false, false)
    end
end

function self:IsDebuff()
    return true
end