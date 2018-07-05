nevermore_w = class({})

LinkLuaModifier("modifier_nevermore_w", "abilities/nevermore/modifier_nevermore_w", LUA_MODIFIER_MOTION_NONE)

function nevermore_w:OnAbilityPhaseStart()
    self:GetCaster().hero:EmitSound("Arena.nevermore.PreQ")
    return true
end

function nevermore_w:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero

    hero:EmitSound("Arena.Slark.PreA")

    FX("particles/melee_attack_blur_configurable.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, {
        cp1 = Vector(300, 0, 0),
        release = true
    })

    return true
end

function nevermore_w:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster():GetParentEntity()
    local pos = hero:GetPos()
    local direction = self:GetDirection()

    ScreenShake(pos, 5, 150, 0.45, 3000, 0, true)

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, 300, direction, math.pi),
        sound = "Arena.Undying.HitA",
        damage = self:GetDamage(),
        knockback = { force = 50, decrease = 5 },
        modifier = { name = "modifier_nevermore_w", ability = self, duration = 2.0 },
        action = function(target)
            local effectPos = target:GetPos() + Vector(0, 0, 64)
            local bloodPath = "particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf"
            FX(bloodPath, PATTACH_ABSORIGIN_FOLLOW, target, {
                cp0 = { ent = target, point = "attach_hitloc" },
                cp2 = (pos - effectPos):Normalized(),
                relese = true
            })
        end
    })
end

function nevermore_w:GetPlaybackRateOverride()
    return 2.5
end

function nevermore_w:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(nevermore_w)