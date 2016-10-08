ld_q = class({})

LinkLuaModifier("modifier_ld_q", "abilities/ld/modifier_ld_q", LUA_MODIFIER_MOTION_NONE)

function ld_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1250,
        graphics = "particles/ld_q/ld_q.vpcf",
        distance = 950,
        hitModifier = { name = "modifier_ld_q", duration = 2.0, ability = self },
        hitFunction = function(self, target)
            if instanceof(target, Hero) or instanceof(target, Rune) then
                for _, modifier in pairs(target:AllModifiers()) do
                    if modifier.CheckState and modifier:CheckState()[MODIFIER_STATE_ROOTED] and modifier:GetCaster() ~= modifier:GetParent() then
                        target:EmitSound("Arena.LD.HitQ2")
                        target:Damage(hero)
                        return
                    end
                end
            end
        end,
        hitSound = "Arena.LD.HitQ"
    }):Activate()

    hero:EmitSound("Arena.LD.CastQ")
end

function ld_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function ld_q:GetPlaybackRateOverride()
    return 1.33
end