modifier_dusa_r_aura = class({})
local self = modifier_dusa_r_aura

if IsServer() then
    function self:OnCreated()
        local caster = self:GetCaster()

        caster:StartGesture(ACT_DOTA_MEDUSA_STONE_GAZE)
        caster:GetParentEntity():EmitSound("Arena.Medusa.CastR.Loop")

        local origin = caster:GetOrigin()
        local index = FX("particles/units/heroes/hero_medusa/medusa_stone_gaze_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, {
            cp1 = { point = "attach_head", ent = caster }
        })

        self:AddParticle(index, false, false, -1, false, false)
    end

    function self:OnDestroy()
        self:GetCaster():FadeGesture(ACT_DOTA_MEDUSA_STONE_GAZE)
        self:GetCaster():GetParentEntity():StopSound("Arena.Medusa.CastR.Loop")
    end
end

function self:IsAura()
    return true
end

function self:GetAuraRadius()
    return 600
end

function self:GetAuraDuration()
    return 0.1
end

function self:GetModifierAura()
    return "modifier_dusa_r_target"
end

function self:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function self:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function self:GetAuraEntityReject(entity)
    if entity == self:GetCaster() then
        return true
    end

    if entity:HasModifier("modifier_dusa_r") then
        return true
    end

    local hero = self:GetCaster():GetParentEntity()

    return not Filters.Cone(hero:GetPos(), 600, hero:GetFacing(), math.pi)(entity:GetParentEntity())
end