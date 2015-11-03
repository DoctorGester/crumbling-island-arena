sven_e = class({})
LinkLuaModifier("modifier_sven_e", "abilities/sven/modifier_sven_e", LUA_MODIFIER_MOTION_NONE)

function sven_e:GetChannelTime()
    local enraged = self:GetCaster():HasModifier("modifier_sven_r") -- Can't use IsEnraged on the client

    if enraged then
        return 0.01
    end

    return 0.4
end

function sven_e:OnSpellStart()
    self:GetCaster().hero:EmitSound("Arena.Sven.CastE")
end

function sven_e:GetChannelAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_3
end

function sven_e:OnChannelFinish(interrupted)
    if interrupted then return end

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()
    local ability = self

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    local effect = ImmediateEffectPoint("particles/econ/items/sven/sven_warcry_ti5/sven_spell_warcry_ti_5.vpcf", PATTACH_ABSORIGIN, hero, hero:GetPos())
    ParticleManager:SetParticleControl(effect, 2, hero:GetPos())

    hero:AddNewModifier(hero, self, "modifier_sven_e", {})
    hero:SetFacing(direction)

    local index = 0
    local damaged = {}
    local dashData = {}
    dashData.hero = hero
    dashData.to = target
    dashData.velocity = 200
    dashData.onArrival =
        function (hero)
            hero:RemoveModifier("modifier_sven_e")
        end

    dashData.positionFunction =
        function(position, data)
            local center = data.to + (data.from - data.to) / 2
            local diff = data.to - position
            local rel = math.min((data.to - center):Length2D() / (position - center):Length2D(), 1.5)
            data.velocity = (rel * 600 + 100) / 30
            local newPos = position + (diff:Normalized() * data.velocity)

            Spells:MultipleHeroesDamage(hero,
                function (attacker, target)
                    if target ~= attacker and not damaged[target] then
                        local tp = target:GetPos()

                        if SegmentCircleIntersection(position, newPos, tp, target:GetRad() * 2) then
                            damaged[target] = true

                            local between = ClosestPointToSegment(newPos, position, tp)
                            KnockbackUnit(target, between, 0.4, 300, 0, true)

                            local effect = ImmediateEffectPoint("particles/econ/items/earthshaker/earthshaker_gravelmaw/earthshaker_fissure_dust_gravelmaw.vpcf", PATTACH_ABSORIGIN, hero, tp)
                            ParticleManager:SetParticleControl(effect, 1, between + (tp - between):Normalized() * 300)

                            target:EmitSound("Arena.Sven.HitE")

                            return true
                        end

                        return false
                    end
                end
            )

            index = index + 1

            if index % 2 == 0 then
                ImmediateEffectPoint("particles/econ/items/rubick/rubick_force_gold_ambient/rubick_telekinesis_force_dust_gold.vpcf", PATTACH_ABSORIGIN, hero, position)
            end

            if index % 5 == 0 then
                hero:EmitSound("Arena.Sven.StepE")
            end

            return newPos
        end

    Spells:Dash(dashData)
end