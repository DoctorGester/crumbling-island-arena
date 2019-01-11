nevermore_r = class({})

LinkLuaModifier("modifier_nevermore_r", "abilities/nevermore/modifier_nevermore_r", LUA_MODIFIER_MOTION_NONE)

function nevermore_r:GetPlaybackRateOverride()
    return 1.05
end

function nevermore_r:GetChannelAnimation()
    return ACT_DOTA_CAST_ABILITY_6
end

function nevermore_r:GetChannelTime()
    return 1.75
end

function nevermore_r:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()
    local path = "particles/units/heroes/hero_nevermore/nevermore_wings.vpcf"
    self.particle =  FX(path, PATTACH_ABSORIGIN_FOLLOW, hero, {
        cp5 = { point = "attach_arm_R" },
        cp6 = { point = "attach_arm_L" },
        release = false
    })

    hero:EmitSound("Arena.Nevermore.CastR")
    hero:EmitSound("Arena.Nevermore.CastR.Voice")
end

function nevermore_r:OnChannelFinish(interrupted)
    local hero = self:GetCaster().hero

    hero:StopSound("Arena.Nevermore.CastR")

    if interrupted then
        hero:StopSound("Arena.Nevermore.CastR.Voice")

        if self.particle then
            DFX(self.particle)
            self.particle = nil
        end

        return
    end

    ScreenShake(hero:GetPos(), 5, 150, 0.45, 3000, 0, true)
    hero:EmitSound("Arena.Nevermore.FinishR")

    local totalProjectiles = 12

    for i = 1, totalProjectiles do
        local angle = (math.pi * 2.0 / totalProjectiles) * i
        local direction = Vector(math.cos(angle), math.sin(angle))

        DistanceCappedProjectile(hero.round, {
            ability = self,
            owner = hero,
            from = hero:GetPos() + Vector(0, 0, 96) + direction * 80,
            to = hero:GetPos() + Vector(0, 0, 96) + direction * 1200,
            damagesTrees = true,
            continueOnHit = true,
            speed = 1000,
            radius = 96,
            graphics = "particles/nevermore_r/nevermore_r_projectile.vpcf",
            distance = 1200,
            hitSound = "Arena.Nevermore.CastA",
            screenShake = { 5, 150, 0.15, 3000, 0, true },
            hitModifier = { name = "modifier_nevermore_r", duration = 3.0, ability = self }
        }):Activate()
    end

    FX("particles/nevermore_r/nevermore_r_requiemofsouls.vpcf", PATTACH_ABSORIGIN, hero, {
        cp1 = Vector(totalProjectiles, 0, 0),
        release = true
    })

    ParticleManager:ReleaseParticleIndex(self.particle)
    self.particle = nil
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(nevermore_r)