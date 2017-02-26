wr_e = class({})
LinkLuaModifier("modifier_wr_e", "abilities/wr/modifier_wr_e", LUA_MODIFIER_MOTION_NONE)

function wr_e:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()

    FX("particles/wr_e/wr_e.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, { release = true })

    hero:AreaEffect({
        ability = self,
        filter = Filters.Area(hero:GetPos(), 400),
        action = function(victim)
            local direction = (victim:GetPos() - hero:GetPos())

            SoftKnockback(victim, hero, direction, 30 + (1 - direction:Length2D() / 400) * 50, { decrease = 4 })
        end
    })

    hero:AddNewModifier(hero, self, "modifier_wr_e", { duration = 2.5 })
    hero:EmitSound("Arena.WR.CastE")

    ScreenShake(hero:GetPos(), 5, 150, 0.25, 3000, 0, true)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(wr_e)