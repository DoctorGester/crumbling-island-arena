ogre_w = class({})

function ogre_w:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero

    self.spell = hero:GetCurrentSpell()
    hero:SpendCurrentSpell()
    CreateAOEMarker(hero, hero:GetPos(), 300, 0.4, Vector(255, 106, 0))

    return true
end

function ogre_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = hero:GetPos()

    hero:AreaEffect({
        filter = Filters.Area(target, 300),
        filterProjectiles = true,
        damage = self.spell.damage,
        onlyHeroes = true,
        hitAllies = true,
        hitSelf = true,
        modifier = {
            name = self.spell.modifier,
            duration = self.spell.duration,
            ability = self
        },
        action = function(target)
            if not self.spell.damage then
                target:Heal()
            end
        end
    })

    hero:EmitSound("Arena.Ogre.CastW")
    hero:EmitSound(self.spell.sound)

    ScreenShake(target, 5, 150, 0.25, 2000, 0, true)

    if self.spell.explosion then
        hero:ExplosionEffect(self.spell, target)
    end
end

function ogre_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function ogre_w:GetPlaybackRateOverride()
    return 1.8
end