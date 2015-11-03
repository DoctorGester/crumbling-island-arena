cm_w = class({})

function cm_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local startPos = self:GetInitialPosition()
    local maxDistance = 800
    local castTime = 0.9
    local endPos = startPos + self:GetDirectionVector() * maxDistance
    local timePassed = 0
    local damaged = {}
    local ability = self

    Timers:CreateTimer(
        function()
            timePassed = timePassed + 0.1

            function GetPositionForTime(time)
                return startPos + (endPos - startPos):Normalized() * (maxDistance * (time / castTime))
            end

            if timePassed < castTime then
                local effectPos = GetPositionForTime(timePassed)
                ImmediateEffectPoint("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf", PATTACH_CUSTOMORIGIN, hero, effectPos)
            end

            if timePassed >= 0.4 then
                local damagePos = GetPositionForTime(timePassed - 0.4)

                local hit = Spells:MultipleHeroesDamage(hero,
                    function (attacker, target)
                        local distance = (target:GetPos() - damagePos):Length2D()

                        if not damaged[target] and target ~= attacker and distance <= 128 then
                            local frozen = hero:IsFrozen(target)
                            hero:Freeze(target, ability)
                            damaged[target] = true

                            return frozen
                        end

                        return false
                    end
                )

                local sound = "Arena.CM.CastW"
                if hit then sound = "Arena.CM.HitW" end

                EmitSoundOnLocationWithCaster(damagePos, sound, hero.unit)
                ImmediateEffectPoint("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_arcana_ground_ambient.vpcf", PATTACH_CUSTOMORIGIN, hero, damagePos)
            end

            if timePassed >= castTime + 0.4 then return end

            return 0.1
        end
    )
end

function cm_w:GetCastAnimation()
    return ACT_DOTA_ATTACK
end