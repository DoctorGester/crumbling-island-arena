pa_w = class({})

function pa_w:OnSpellStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("DOTA_Item.Daedelus.Crit")

    Timers:CreateTimer(0.3,
        function()
            local particle = "particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser_b.vpcf"
            ImmediateEffect(particle, PATTACH_ABSORIGIN_FOLLOW, hero)

            hero:AreaEffect({
                filter = Filters.Area(hero:GetPos(), 256),
                action = function(victim)
                    victim:Damage(hero)

                    local direction = (victim:GetPos() - hero:GetPos()):Normalized()
                    local blood = ImmediateEffect("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
                    ParticleManager:SetParticleControlEnt(blood, 0, victim:GetUnit(), PATTACH_POINT_FOLLOW, "attach_hitloc", victim:GetPos(), true)
                    ParticleManager:SetParticleControlForward(blood, 0, direction)
                    ParticleManager:SetParticleControl(blood, 2, direction * 1000)
                end
            })

            GridNav:DestroyTreesAroundPoint(hero:GetPos(), 256, true, 1)
        end
    )

end

function pa_w:GetCastAnimation()
    return ACT_DOTA_ATTACK_EVENT
end