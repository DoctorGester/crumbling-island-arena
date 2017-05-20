slark_a = class({})

LinkLuaModifier("modifier_slark_a", "abilities/slark/modifier_slark_a", LUA_MODIFIER_MOTION_NONE)

function slark_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Slark.PreA")

    return true
end

function slark_a:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local damage = self:GetDamage()
    local force = 20

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, 300, forward, math.pi),
        sound = "Arena.Slark.HitA",
        damage = damage,
        knockback = { force = force, decrease = 3 },
        isPhysical = true,
        action = function(target)
            if instanceof(target, Hero) and hero:GetHealth() < hero:GetUnit():GetMaxHealth() then
                FX("particles/units/heroes/hero_slark/slark_essence_shift.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, {
                    cp0 = { ent = target, point = "attach_hitloc" },
                    cp1 = { ent = hero, point = "attach_hitloc" },
                    release = true
                })

                hero:Heal(1)

                if target:Alive() then
                    hero:AddNewModifier(hero, self, "modifier_slark_a", { duration = 6 }):SetTarget(target)
                end
            end
        end
    })
end

function slark_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function slark_a:GetPlaybackRateOverride()
    return 4
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(slark_a, nil, "particles/melee_attack_blur.vpcf")