am_q = class({})
local self = am_q

LinkLuaModifier("modifier_am_damage", "abilities/am/modifier_am_damage", LUA_MODIFIER_MOTION_NONE)

function self:OnAbilityPhaseStart()
    FX("particles/am_q/am_q.vpcf", PATTACH_ABSORIGIN, self:GetCaster(), { release = true })
    self:GetCaster():EmitSound("Arena.AM.PreQ")

    return true
end

function self:DealDamage(target)
    local modifier = target:FindModifier("modifier_am_damage")
    local hero = self:GetCaster():GetParentEntity()

    if not modifier then
        modifier = target:AddNewModifier(hero, self, "modifier_am_damage", { duration = 4 })
    end

    if modifier then
        local stacks = modifier:GetStackCount()

        stacks = stacks + 1

        target:EmitSound("Arena.AM.Hit")
        
        if stacks == 3 then
            target:Damage(hero)
            modifier:Destroy()

            target:EmitSound("Arena.AM.Proc")
        else
            modifier:SetStackCount(stacks)
        end

        local path = string.format("particles/am_damage/am_damage_%s.vpcf", ({ "single", "double", "triple" })[stacks])
        local particle = FX(path, PATTACH_ABSORIGIN_FOLLOW, target, {})

        self.previousParticles = self.previousParticles or {}

        if self.previousParticles[target] then
            ParticleManager:DestroyParticle(self.previousParticles[target], true)
            ParticleManager:ReleaseParticleIndex(self.previousParticles[target])
        end

        self.previousParticles[target] = particle
    end
end

function self:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AreaEffect({
        filter = Filters.Area(hero:GetPos(), 300),
        filterProjectiles = true,
        action = function(target)
            self:DealDamage(target)
        end
    })
end

function self:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function self:GetPlaybackRateOverride()
    return 1.66
end