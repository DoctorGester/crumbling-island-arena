Ogre = class({}, {}, Hero)

function Ogre:constructor()
    getbase(Ogre).constructor(self)

    self.spells = {}
    self.currentSpell = nil
    self.currentSpellParticle = nil
    self.ultTick = 0

    self:AddSpell("modifier_ogre_1", "particles/ogre/projectile_ogre_1.vpcf", {
        path = "particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf",
        cp = { [1] = Vector(300, 1, 1) }
    }, 2.0, 1, "Arena.Ogre.HitQ.Slow")

    self:AddSpell("modifier_ogre_2", "particles/ogre/projectile_ogre_2.vpcf", {
        path = "particles/ogre/ogre_explosion_2.vpcf",
    }, 3.0, 0, "Arena.Ogre.HitQ.Speed")

    self:AddSpell("modifier_ogre_3", "particles/ogre/projectile_ogre_3.vpcf", {
        path = "particles/ogre/ogre_explosion_3.vpcf",
    }, 2.0, 3, "Arena.Ogre.HitQ.Root")

    self:AddSpell("modifier_ogre_4", "particles/ogre/projectile_ogre_4.vpcf", {
        path = "particles/units/heroes/hero_drow/drow_silence.vpcf",
        cp = { [1] = Vector(300, 1, 1) }
    }, 2.5, 2, "Arena.Ogre.HitQ.Invis")

    self:AddSpell("modifier_ogre_5", "particles/ogre/projectile_ogre_5.vpcf", {
        path = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf"
    }, 2.0, 5, "Arena.Ogre.HitQ.Silence")

    self:AddSpell("modifier_ogre_6", "particles/ogre/projectile_ogre_6.vpcf", {
        path = "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf",
    }, 1.5, 4, "Arena.Ogre.HitQ.Hex")

    self:AddSpell("modifier_stunned_lua", "particles/ogre/projectile_ogre_7.vpcf", {
        path = "particles/ogre/ogre_explosion_7.vpcf"
    }, 1.0, 6, "Arena.Ogre.HitQ.Stun")
end

function Ogre:RollRandomSpell()
    self.currentSpell = self.spells[RandomInt(1, #self.spells)]

    if not self:HasModifier("modifier_ogre_r") and self.currentSpellParticle then
        ParticleManager:DestroyParticle(self.currentSpellParticle, false)
        ParticleManager:ReleaseParticleIndex(self.currentSpellParticle)
        self.currentSpellParticle = nil
    end

    if not self.currentSpellParticle then
        self.currentSpellParticle = ParticleManager:CreateParticle("particles/ogre/msg_ogre_spell.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetUnit())
    end

    local firstSprite = 0
    local firstColor = Vector(38, 182, 0)

    if self.currentSpell.damage then
        firstSprite = 1
        firstColor = Vector(209, 24, 33)
    end

    ParticleManager:SetParticleControl(self.currentSpellParticle, 1, Vector(firstSprite, self.currentSpell.sprite, 0))
    ParticleManager:SetParticleControl(self.currentSpellParticle, 2, firstColor)
    ParticleManager:SetParticleControl(self.currentSpellParticle, 3, Vector(255, 255, 255))
end

function Ogre:ExplosionEffect(spell, point)
    local particle = ParticleManager:CreateParticle(spell.explosion.path, PATTACH_ABSORIGIN, self:GetUnit())

    ParticleManager:SetParticleControl(particle, 0, point)

    if spell.explosion.cp then
        for key, value in pairs(spell.explosion.cp) do
            ParticleManager:SetParticleControl(particle, key, value)
        end
    end

    ParticleManager:ReleaseParticleIndex(particle)
end

function Ogre:GetCurrentSpell()
    return self.currentSpell
end

function Ogre:SpendCurrentSpell()
    ParticleManager:DestroyParticle(self.currentSpellParticle, false)
    ParticleManager:ReleaseParticleIndex(self.currentSpellParticle)

    self.currentSpell = nil
    self.currentSpellParticle = nil
end

function Ogre:AddSpell(modifierName, effectName, explosion, duration, sprite, sound)
    table.insert(self.spells, OgreSpell(true, modifierName, effectName, explosion, duration, sprite, sound))
    table.insert(self.spells, OgreSpell(false, modifierName, effectName, explosion, duration, sprite, sound))
end

function Ogre:Update()
    getbase(Ogre).Update(self)

    self:FindAbility("ogre_q"):SetActivated(self.currentSpell ~= nil)
    self:FindAbility("ogre_w"):SetActivated(self.currentSpell ~= nil)
    self:FindAbility("ogre_e"):SetActivated(not self:HasModifier("modifier_ogre_r"))

    if self:HasModifier("modifier_ogre_r") then
        self.ultTick = self.ultTick + 1

        if self.ultTick % 3 == 0 then
            self:RollRandomSpell()
        end
    end
end

OgreSpell = class({})

function OgreSpell:constructor(damage, modifierName, effectName, explosion, duration, sprite, sound)
    self.damage = damage
    self.modifier = modifierName
    self.effectName = effectName
    self.explosion = explosion
    self.duration = duration
    self.sprite = sprite
    self.sound = sound
end