lycan_w = class({})

function lycan_w:OnAbilityPhaseStart()
    self:GetCaster().hero:EmitSound("Arena.Lycan.CastW")
    return true
end

function lycan_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local point = hero:GetPos() + hero:GetFacing() * 128

    local hit = Spells:MultipleHeroesDamage(hero,
        function (hero, target)
            local distance = (target:GetPos() - point):Length2D()

            if target ~= hero and distance <= 128 then
                if hero:IsTransformed() and hero:IsBleeding(target) then
                    target:Damage(hero)
                end

                hero:MakeBleed(target)
                return true
            end

            return false
        end
    )

    if hit then
        hero:EmitSound("Arena.Lycan.HitW")
    end
end

function lycan_w:GetCastAnimation()
    return ACT_DOTA_ATTACK
end