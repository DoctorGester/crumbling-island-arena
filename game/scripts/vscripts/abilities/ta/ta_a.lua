ta_a = class({})

function ta_a:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    local target = hero:GetPos() + direction:Normalized() * 500
    local height = Vector(0, 0, 64)

    local path = hero:GetMappedParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_psi_blade.vpcf")

    FX(path, PATTACH_POINT_FOLLOW, hero, {
        cp0 = { ent = hero, point = "attach_attack2" },
        cp1 = target + height,
        cp2 = target + height,
        release = true
    })

    local damage = self:GetDamage()

    if hero:HasModifier("modifier_ta_r") then
        damage = damage * 2
    end

    local hurt = hero:AreaEffect({
        ability = self,
        filter = Filters.Line(hero:GetPos(), target, 64),
        sound = "Arena.TA.HitA",
        isPhysical = true,
        damage = damage,
        action = function(victim)
            local effect = ImmediateEffect(hero:GetMappedParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_meld_hit.vpcf"), PATTACH_ABSORIGIN, hero)
            ParticleManager:SetParticleControlForward(effect, 0, direction:Normalized())
            ParticleManager:SetParticleControl(effect, 1, victim:GetPos())
            ParticleManager:SetParticleControl(effect, 3, victim:GetPos())
        end
    })

    hero:EmitSound("Arena.TA.CastA")

    if hurt and hero:HasModifier("modifier_ta_r_shield") then
        hero:FindAbility("ta_e"):EndCooldown()
    end
end

function ta_a:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function ta_a:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(ta_a)