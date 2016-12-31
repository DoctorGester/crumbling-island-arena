qop_q = class({})

LinkLuaModifier("modifier_qop_q", "abilities/qop/modifier_qop_q", LUA_MODIFIER_MOTION_NONE)

function qop_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local hadCharges = hero:FindAbility("qop_r"):HasCharges(self)

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 1250,
        graphics = "particles/qop_q/qop_q.vpcf",
        distance = 950,
        hitSound = "Arena.QOP.HitQ",
        hitFunction = function(_, victim)
            victim:AddNewModifier(hero, self, "modifier_qop_q", { duration = 3.0, heals = hadCharges })
        end
    }):Activate()

    hero:FindAbility("qop_r"):AbilityUsed(self)
    hero:EmitSound("Arena.QOP.CastQ")
end

function qop_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function qop_q:GetPlaybackRateOverride()
    return 1.5
end