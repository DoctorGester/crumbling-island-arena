pudge_w = class({})

function pudge_w:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster():GetParentEntity()
    local pos = hero:GetPos()
    local direction = self:GetDirection()

    ScreenShake(pos, 5, 150, 0.45, 3000, 0, true)

    local hitAnyone = hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, 300, direction, math.pi),
        sound = "Arena.Pudge.HitW",
        damage = self:GetDamage(),
        action = function(target)
            local effectPos = target:GetPos() + Vector(0, 0, 64)

            local bloodPath = "particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf"
            FX(bloodPath, PATTACH_ABSORIGIN_FOLLOW, target, {
                cp0 = { ent = target, point = "attach_hitloc" },
                cp2 = (pos - effectPos):Normalized(),
                relese = true
            })

            local healPath = "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok.vpcf"
            FX(healPath, PATTACH_ABSORIGIN_FOLLOW, hero, {
                cp1 = hero:GetPos(),
                release = true
            })

            hero:Heal(2)
        end
    })

    if hitAnyone then
        hero:EmitSound("Arena.Pudge.Meat.Voice")
        hero:EmitSound("Arena.Pudge.Meat")
    end

    local times = 0
    Timers:CreateTimer(0, function()
        hero:EmitSound("Arena.Pudge.CastW")

        if times == 2 then
            return
        end

        times = times + 1

        return 0.2
    end)
end

function pudge_w:GetCastAnimation()
    return ACT_DOTA_CHANNEL_ABILITY_4
end

function pudge_w:GetPlaybackRateOverride()
    return 3
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(pudge_w)