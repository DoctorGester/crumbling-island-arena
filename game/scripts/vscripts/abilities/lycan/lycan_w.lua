lycan_w = class({})

function lycan_w:OnAbilityPhaseStart()
    self:GetCaster().hero:EmitSound("Arena.Lycan.CastW")
    return true
end

function lycan_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    direction = direction:Normalized()

    hero:AreaEffect({
        filter = Filters.Cone(hero:GetPos(), 300, direction, math.pi),
        sound = "Arena.Lycan.HitW",
        damage = true,
        action = function(target)
            if hero:IsTransformed() and hero:IsBleeding(target) then
                target:Damage(hero)
            end

            hero:MakeBleed(target)
        end
    })

    local effect = ParticleManager:CreateParticle("particles/lycan_w/lycan_w.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(effect, 0, hero:GetPos())
    ParticleManager:SetParticleControlForward(effect, 0, direction)
    ParticleManager:ReleaseParticleIndex(effect)
end

function lycan_w:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end