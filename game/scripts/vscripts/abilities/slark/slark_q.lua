slark_q = class({})

LinkLuaModifier("modifier_slark_q", "abilities/slark/modifier_slark_q", LUA_MODIFIER_MOTION_NONE)

function slark_q:OnAbilityPhaseStart()
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
    self:GetCaster():EmitSound("Arena.Slark.PreQ")

    return true
end

function slark_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    
    hero:AreaEffect({
        filter = Filters.Cone(pos, 300, forward, math.pi),
        sound = "Arena.Slark.CastQ",
        action = function(target)
            if instanceof(target, Hero) then
                local index = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_essence_shift.vpcf", PATTACH_ABSORIGIN_FOLLOW, target.unit)
                ParticleManager:SetParticleControlEnt(index, 0, target.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetPos(), true)
                ParticleManager:SetParticleControlEnt(index, 1, hero:GetUnit(), PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetPos(), true)
                ParticleManager:ReleaseParticleIndex(index)

                target:Damage(hero)

                if hero:GetHealth() < 5 then
                    hero:Heal()

                    if target:Alive() then
                        hero:AddNewModifier(hero, self, "modifier_slark_q", { duration = 6 }):SetTarget(target)
                    end
                end
            else
                target:Damage(hero)
            end
        end
    })
end

function slark_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function slark_q:GetPlaybackRateOverride()
    return 2
end