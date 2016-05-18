ta_e = class({})

function ta_e:OnAbilityPhaseStart()
    self:GetCaster().hero:EmitSound("Arena.TA.CastE")
    return true
end

function ta_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local casterPos = hero:GetPos()
    local target = self:GetCursorPosition()
    local direction = (target - casterPos):Normalized()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    if (target - casterPos):Length2D() > 400 then
        target = casterPos + direction * 400
    end

    ImmediateEffectPoint("particles/econ/events/ti4/blink_dagger_start_ti4.vpcf", PATTACH_ABSORIGIN, hero, hero:GetPos() + Vector(0, 0, 32))

    GridNav:DestroyTreesAroundPoint(target, 128, true)
    hero:FindClearSpace(target, true)

    ImmediateEffectPoint("particles/econ/events/ti4/blink_dagger_end_ti4.vpcf", PATTACH_ABSORIGIN, hero, hero:GetPos() + Vector(0, 0, 32))

    StartAnimation(self:GetCaster(), { duration = 0.3, activity = ACT_DOTA_ATTACK, rate = 2, translate = "meld" })
    hero:EmitSound("Arena.TA.EndE")
end

function ta_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function ta_e:GetPlaybackRateOverride()
    return 2
end