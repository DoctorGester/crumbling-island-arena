pl_a = class({})
--local self = pl_a

LinkLuaModifier("modifier_pl_a", "abilities/pl/modifier_pl_a", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_a_dmg", "abilities/pl/modifier_pl_a_dmg", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_a_animation", "abilities/pl/modifier_pl_a_animation", LUA_MODIFIER_MOTION_NONE)

function pl_a:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Arena.PL.PreQ")

    return true
end

function pl_a:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local direction = self:GetDirection()
    local pos = hero:GetPos()
    local force = 20
    local damage = 1
    local mod = hero:FindModifier("modifier_pl_a_dmg")

    if mod then
        damage = damage * 2
        force = force * 1.5
        sound = { "Arena.PL.HitA", "Arena.PL.HitA2" }

        mod:Destroy()
    end

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, 350, direction, math.pi),
        sound = "Arena.PL.HitQ",
        hitAllies = true,
        damagesTrees = true,
        knockback = { force = force, decrease = 3 },
        isPhysical = true,
        action = function(target)
            --[[
            local blocked = target:AllowAbilityEffect(self, self.ability) == false
            local blocked_2 = target:AllowAbilityEffect(EntityPLIllusion, self.ability) == false  
            local blocked_3 = target:AllowAbilityEffect(Hero, self:GetAbility()) == false --]] -- Ничего из это, по сути, не оказывает никакого эффекта вообще.
            --local ally = target.owner.team == self.hero.owner.team
            --if not blocked and target.owner.team ~= hero.owner.team then
            if target.owner.team ~= hero.owner.team then
                --target:Damage(hero, 1)
                knockback = 0
                target:Damage(hero, damage, true)
            end

            --if not blocked then
            if target.owner.team == hero.owner.team then  
                if instanceof(target, EntityPLIllusion) or (instanceof(target, Hero) and target:GetName() == "npc_dota_hero_phantom_lancer") then
                target:GetUnit():Interrupt()
                hero.round.spells:InterruptDashes(target)

                if instanceof(target, EntityPLIllusion) then
                    target:Refresh()
                end

                target:EmitSound("Arena.PL.CastQ")

                local dash = nil
                dash = Dash(target, target:GetPos() + direction * 1200, 1800, {
                    modifier = { name = "modifier_pl_a", ability = self },
                    ability = self, -- ?
                    forceFacing = true,
                    damagesTrees = true, -- not working for some reason
                    hitParams = {
                        action = function(victim)
                            target:EmitSound("Arena.PL.HitQ2")

                            dash:Interrupt()

                            target:FindClearSpace(victim:GetPos() + direction * 180, true)
                            target:SetFacing(-direction)

                            if instanceof(victim, Obstacle) then
                                victim:DealOneDamage(self)
                            else
                                victim:Damage(hero, damage * 2) 
                            end

                            FX("particles/units/heroes/hero_phantom_lancer/phantomlancer_spiritlance_flash_target.vpcf", PATTACH_WORLDORIGIN, victim, {
                                cp0 = victim:GetPos() + Vector(0, 0, 64),
                                release = true
                            })


                        end
                    }
                })

                FX("particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_aoe.vpcf", PATTACH_ABSORIGIN, target, {
                    cp2 = Vector(150, 1, 1),
                    cp3 = Vector(1, 0, 0),
                    release = true
                })
                end
            end
        end
    }) 
end

function pl_a:GetCastAnimation()
    return ACT_DOTA_SPAWN
end

function pl_a:GetPlaybackRateOverride()
    return 4.0
end

function pl_a:GetIntrinsicModifierName()
    return "modifier_pl_a_animation"
end

if IsClient() then
    require("wrappers")
end

--Wrappers.AttackAbility(pl_a, nil, "particles/melee_attack_blur.vpcf")
Wrappers.AttackAbility(pl_a)