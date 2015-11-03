sven_w = class({})

LinkLuaModifier("modifier_sven_w_animation_one", "abilities/sven/modifier_sven_w_animation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sven_w_animation_two", "abilities/sven/modifier_sven_w_animation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sven_w_slow", "abilities/sven/modifier_sven_w_slow", LUA_MODIFIER_MOTION_NONE)

function sven_w:GetBehavior()
    local enraged = self:GetCaster():HasModifier("modifier_sven_r") -- Can't use IsEnraged on the client

    if enraged then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end

    return DOTA_ABILITY_BEHAVIOR_POINT
end

function sven_w:RemoveAnimationTranslation()
    local hero = self:GetCaster().hero
    hero:RemoveModifier("modifier_sven_w_animation_one")
    hero:RemoveModifier("modifier_sven_w_animation_two")
end

function sven_w:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:AddNewModifier(hero, self, "modifier_sven_w_animation_one", {})
    hero:AddNewModifier(hero, self, "modifier_sven_w_animation_two", {})

    return true
end

function sven_w:OnAbilityPhaseInterrupted()
    self:RemoveAnimationTranslation()
end

function sven_w:Shout(direction)
    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = pos + direction:Normalized() * Vector(500, 500, 0)
    local target = hero:GetPos() + direction:Normalized() * 500

    local effect = ImmediateEffect("particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf", PATTACH_CUSTOMORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 0, hero:GetPos())
    ParticleManager:SetParticleControl(effect, 1, target)
    ParticleManager:SetParticleControlForward(effect, 0, direction:Normalized())

    Spells:MultipleHeroesModifier(hero, self, "modifier_sven_w_slow", { duration = "2" },
        function (source, heroTarget)
            local distance = (heroTarget:GetPos() - pos):Length2D()
            return distance <= 500 and hero:FilterCone(heroTarget:GetPos(), pos, target, 500)
        end
    )
end

function sven_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()
    local ability = self

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    self:RemoveAnimationTranslation()


    if not hero:IsEnraged() then
        self:Shout(direction)
    else
        for i = 0, 8 do
            local an = math.pi / 4 * i
            self:Shout(Vector(math.cos(an), math.sin(an)))
        end
    end

    hero:EmitSound("Arena.Sven.CastW")
end

function sven_w:GetCastAnimation()
    return ACT_DOTA_ATTACK
end