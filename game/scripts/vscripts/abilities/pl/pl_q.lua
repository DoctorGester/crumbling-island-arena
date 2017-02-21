pl_q = class({})
local self = pl_q

LinkLuaModifier("modifier_pl_q", "abilities/pl/modifier_pl_q", LUA_MODIFIER_MOTION_NONE)

function self:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Arena.PL.PreQ")

    return true
end

function self:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local direction = self:GetDirection()
    local pos = hero:GetPos()

    if hero:AreaEffect({
        filter = Filters.Cone(pos, 350, direction, math.pi),
        sound = "Arena.PL.HitQ",
        hitAllies = true,
        action = function(target)
            if target.owner.team ~= hero.owner.team then
                target:Damage(hero)
            end

            if instanceof(target, EntityPLIllusion) or (instanceof(target, Hero) and target:GetName() == "npc_dota_hero_phantom_lancer") then
                target:GetUnit():Interrupt()
                hero.round.spells:InterruptDashes(target)

                if instanceof(target, EntityPLIllusion) then
                    target:Refresh()
                end

                target:EmitSound("Arena.PL.CastQ")

                local dash = nil
                dash = Dash(target, target:GetPos() + direction * 1200, 1800, {
                    modifier = { name = "modifier_pl_q", ability = self },
                    forceFacing = true,
                    hitParams = {
                        action = function(victim)
                            target:EmitSound("Arena.PL.HitQ2")

                            dash:Interrupt()

                            target:FindClearSpace(victim:GetPos() + direction * 180, true)
                            target:SetFacing(-direction)
                            victim:Damage(hero)

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
    }) then
        ScreenShake(pos, 5, 150, 0.45, 3000, 0, true)
    end
end

function self:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function self:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(pl_q)