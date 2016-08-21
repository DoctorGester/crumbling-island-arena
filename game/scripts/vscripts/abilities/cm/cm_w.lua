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

    if self:GetDirectionVector():Length2D() == 0 then
        endPos = startPos + (startPos - hero:GetPos()):Normalized() * maxDistance
    end

    Timers:CreateTimer(
        function()
            timePassed = timePassed + 0.1

            function GetPositionForTime(time)
                return startPos + (endPos - startPos):Normalized() * (maxDistance * (time / castTime))
            end

            if timePassed < castTime then
                local effectPos = GetPositionForTime(timePassed)
                local startingHeight = 1600
                local offset = Vector(-320, 490, startingHeight)
                local skies = effectPos + offset
                local time = 0.4
                local speed = startingHeight / time

                EmitSoundOnLocationWithCaster(effectPos, "Arena.CM.PreW", hero.unit)

                if not Spells.TestPoint(effectPos) then
                    effectPos = effectPos - (offset / time) * (MAP_HEIGHT / speed)
                    time = time + MAP_HEIGHT / speed
                end

                local effect = ParticleManager:CreateParticle("particles/cm_w/cm_w.vpcf", PATTACH_CUSTOMORIGIN, hero:GetUnit())
                ParticleManager:SetParticleControl(effect, 0, effectPos)
                ParticleManager:SetParticleControl(effect, 1, skies)
                ParticleManager:SetParticleControl(effect, 2, Vector(time, 0, 0))
                ParticleManager:ReleaseParticleIndex(effect)
            end

            if timePassed >= 0.4 then
                local damagePos = GetPositionForTime(timePassed - 0.4)

                if Spells.TestPoint(damagePos) then
                    local function groupFilter(target)
                        return not damaged[target]
                    end

                    local hit = hero:AreaEffect({
                        filter = Filters.And(Filters.Area(damagePos, 128), groupFilter),
                        action = function(target)
                            local frozen = hero:IsFrozen(target)

                            if frozen then
                                target:Damage(hero)
                            end

                            hero:Freeze(target, ability)
                            damaged[target] = true
                        end
                    })

                    ScreenShake(damagePos, 3, 60, 0.15, 2000, 0, true)
                    Spells:GroundDamage(damagePos, 128, hero)

                    local sound = "Arena.CM.CastW"
                    if hit then sound = "Arena.CM.HitW" end

                    EmitSoundOnLocationWithCaster(damagePos, sound, hero.unit)
                    ImmediateEffectPoint("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_arcana_ground_ambient.vpcf", PATTACH_CUSTOMORIGIN, hero, damagePos)
                end
            end

            if timePassed >= castTime + 0.4 then return end

            return 0.1
        end
    )
end

function cm_w:GetCastAnimation()
    return ACT_DOTA_ATTACK
end