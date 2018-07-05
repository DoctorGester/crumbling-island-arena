EarthSpirit = class({}, nil, Hero)

function EarthSpirit:FindRemnant(point, area, filter)
    local closest = nil
    local distance = 64000

    local remnants = nil

    if filter then
        remnants = self.round.spells:FilterEntities(filter, self:AllRemnants())
    else
        remnants = self:AllRemnants()
    end

    for _, value in pairs(remnants) do
        local toRemnant = (point - value:GetPos()):Length2D()

        if toRemnant <= distance and (not area or toRemnant <= area) then
            closest = value
            distance = toRemnant
        end
    end

    return closest
end

function EarthSpirit:AllRemnants()
    return self.round.spells:FilterEntities(function(ent)
        return instanceof(ent, EarthSpiritRemnant)
    end, self.round.spells:GetValidTargets())
end

function EarthSpirit:FindNonStandRemnantCursor(ability, location)
    local hero = ability:GetCaster():GetParentEntity()

    return hero:FindRemnant(location or ability:GetCursorPosition(), 200,
        function(remnant)
            return remnant.standingHero == nil
        end
    )
end

function EarthSpirit:FindNonHeroStandRemnantCursor(ability, location)
    local hero = ability:GetCaster():GetParentEntity()
    return hero:FindRemnant(location or ability:GetCursorPosition(), 200,
        function(remnant)
            return remnant.standingHero ~= self or remnant.standingHero == nil
        end
    )
end

function EarthSpirit:FindNonEnemyStandRemnantCursor(ability, location)
    local hero = ability:GetCaster():GetParentEntity()
    return hero:FindRemnant(location or ability:GetCursorPosition(), 200,
        function(remnant)
            return remnant.standingHero == self or remnant.standingHero == nil
        end
    )
end

function EarthSpirit:GetRemnantStand()
    return self.round.spells:FilterEntities(function(ent)
        return ent.standingHero == self
    end, self:AllRemnants())[1]
end

function EarthSpirit:HasRemnantStand()
    return self:GetRemnantStand() ~= nil
end

function EarthSpirit:IsInvulnerable()
    return self.invulnerable or self:HasModifier("modifier_earth_spirit_stand")
end

function EarthSpirit:FallFromStand()
    local source = self.unit:FindAbilityByName("earth_spirit_e")
    self:AddNewModifier(self, source, "modifier_earth_spirit_e", {})

    local height = 150

    Timers:CreateTimer(
        function()
            local pos = self:GetPos()
            height = math.max(0, height - 5)
            self:SetPos(Vector(pos.x, pos.y, GetGroundHeight(pos, self.unit) + height))

            if height == 0 then
                self:RemoveModifier("modifier_earth_spirit_e")
                return false
            end

            return 0.01
        end
    )
end

function EarthSpirit:Remove()
    self:StopSound("Arena.Earth.CastE.Loop")
    getbase(EarthSpirit).Remove(self)
end