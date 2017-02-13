am_a = class({})
local self = am_a

LinkLuaModifier("modifier_am_a", "abilities/am/modifier_am_a", LUA_MODIFIER_MOTION_NONE)

function self:OnAbilityPhaseStart()
    local hero = self:GetCaster():GetParentEntity()

    FX(hero:GetMappedParticle("particles/am_a/am_a.vpcf"), PATTACH_ABSORIGIN, hero, { release = true })
    hero:EmitSound("Arena.AM.PreA")

    return true
end

function self:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()
    local sound = "Arena.AM.Hit"
    local mod = hero:FindModifier("modifier_am_a")
    local damage = self:GetDamage()
    local action

    if mod then
        sound = "Arena.AM.Proc"
        damage = damage * 2
        mod:Destroy()
        action = function(target)
            FX("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, {
                release = true
            })

            target:AddNewModifier(hero, self, "modifier_silence_lua", { duration = 1.0 })
        end
    end

    hero:AreaEffect({
        filter = Filters.Area(hero:GetPos(), 300),
        damage = damage,
        sound = sound,
        action = action
    })
end

function self:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function self:GetPlaybackRateOverride()
    return 1.66
end

Wrappers.AttackAbility(self)