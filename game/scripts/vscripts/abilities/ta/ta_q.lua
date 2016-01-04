ta_q = class({})

function ta_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    local target = hero:GetPos() + direction:Normalized() * 500
    local height = Vector(0, 0, 64)

    local effect = ImmediateEffect("particles/units/heroes/hero_templar_assassin/templar_assassin_psi_blade.vpcf", PATTACH_ABSORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 0, hero:GetPos() + height)
    ParticleManager:SetParticleControl(effect, 1, target + height)
    ParticleManager:SetParticleControl(effect, 3, target + height)

    local hurt = Spells:LineDamage(hero, hero:GetPos(), target, 64,
        function(target)
            hero:EmitSound("Arena.TA.HitQ", target:GetPos())
        end
    )

    hero:EmitSound("Arena.TA.CastQ")

    if hurt then
        hero:FindAbility("ta_e"):EndCooldown()
    end
end

function ta_q:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end