earth_spirit_e = class({})

LinkLuaModifier("modifier_earth_spirit_e", "abilities/earth_spirit/modifier_earth_spirit_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earth_spirit_e_animation", "abilities/earth_spirit/modifier_earth_spirit_e", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 600)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local targetRemnant = EarthSpirit:FindNonStandRemnantCursor(self, target)
    local hadStand = false

    if targetRemnant then
        target = targetRemnant:GetPos()
    end

    if hero:HasRemnantStand() then
        hadStand = true
        hero:RemoveRemnantStand()
    end

    Dash(hero, target, 600, {
        loopingSound = "Arena.Earth.CastE.Loop",
        modifier = { name = "modifier_earth_spirit_e", ability = self },
        forceFacing = true,
        arrivalFunction = function()
            if targetRemnant and not targetRemnant.destroyed then
                hero:SetRemnantStand(targetRemnant)
                hero:SetPos(Vector(target.x, target.y, target.z + 150))
            end
        end,
        heightFunction = function(dash, current)
            local d = (dash.from - dash.to):Length2D()
            local x = (dash.from - current):Length2D()
            local y0 = 0
            local y1 = 0

            if hadStand then
                y0 = 150
            end

            if targetRemnant and not targetRemnant.destroyed then
                y1 = 150
            end

            return ParabolaZ2(y0, y1, 100, d, x)
        end
    })
end