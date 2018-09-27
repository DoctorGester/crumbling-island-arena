lc_w = class({})

LinkLuaModifier("modifier_lc_w_shield", "abilities/lc/modifier_lc_w_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lc_w_speed", "abilities/lc/modifier_lc_w_speed", LUA_MODIFIER_MOTION_NONE)

function lc_w:GetCastRange(loc, target)
    if target == nil then
        return 0
    else
        return self.BaseClass.GetCastRange(self, loc, target)
    end
end

--[[function lc_w:FindClosestHero(point)
    local min = math.huge
    local closest = nil

    for _, ent in pairs(list or self.entities) do
        local distance = (ent:GetPos() - point):Length2D()

        if distance < min and distance <= 200 then
            min = distance
            closest = ent
        end
    end

    return closest
end
]]--

function lc_w:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()
    local realHero = hero

    --Wrappers.DirectionalAbility(self)

--[[    hero:AreaEffect({
        ability = self,
        filter = Filters.Area(target, 220),
        hitAllies = true,
        hitSelf = true,
        action = function(victim) table.insert(targets, victim) end
    })

    local target = self:GetCursorPosition()
    local realTarget = self.BaseClass.GetCursorPosition(self)

    local spells = hero.round.spells

    local closest = spells:FindClosest(realTarget, 220,
        spells:FilterEntities(function(ent)
            return instanceof(ent, Hero)
        end, spells:GetValidTargets())
    )

    local isAlly = hero.owner.team == ent.owner.team


    if closest and IsAlly then
        closest:AddNewModifier(hero, self, "modifier_lc_w_shield", { duration = 2 })
        closest:EmitSound("Arena.LC.CastW")
    else
        realHero:AddNewModifier(hero, self, "modifier_lc_w_shield", { duration = 2 })
        realHero:EmitSound("Arena.LC.CastW")
    end
    ]]--
    local target = self:GetCursorPosition()
    local s = hero.round.spells;

    --local function distFrom(o)
    --    return (o:GetPos() - target):Length2D()
    --end

    --local min = math.huge
    local closest = nil

    local targets = {}

    hero:AreaEffect({
        filter = Filters.Area(target, 220), -- + FiltersWrap?
        hitAllies = true,
        hitSelf = true,
        onlyHeroes = true,
        action = function(victim) table.insert(targets, victim) end
    })

    for _, ent in pairs(targets) do
        --local distance = distFrom(ent)
        local isEntHero = instanceof(ent, Hero) ~= nil
        if hero.owner.team == ent.owner.team and instanceof(ent, Hero) then
            print('debug1')
            if ent then
                ent:AddNewModifier(hero, self, "modifier_lc_w_shield", { duration = 2 })
                ent:EmitSound("Arena.LC.CastW")
                print('debug2')
                break
            end
        --[[elseif distance < min and (not isEntHero) and ent == hero then
            print('wtf')
            min = distance
            closest = ent
        --]]
        end
    end

    --[[if closest then
        local target = closest
        target:AddNewModifier(hero, self, "modifier_lc_w_shield", { duration = 2 })
        target:EmitSound("Arena.LC.CastW")
    end--]]

    --local target = self:GetCursorPosition()
    --local closestHero = hero:FindClosestHero(target)
    --local target = self:GetCursorTarget() and self:GetCursorTarget():GetParentEntity() or hero
    --[[hero:AreaEffect({
        ability = self,
        filter = Filters.Area(target, 200),
        filterProjectiles = true,
    })
    --
    if target == nil then
        local closest = FindClosestHero(self:GetPos(), 200, s:FilterEntities(
            function(t) return t.owner.team == self.owner.team end,
            s:GetHeroTargets()
        ))
    --

    if closestHero then
        target = closestHero
    end

    target:AddNewModifier(hero, self, "modifier_lc_w_shield", { duration = 2 })
    target:EmitSound("Arena.LC.CastW")
    ]]--
end

function lc_w:Cast(target)
    local hero = self:GetCaster():GetParentEntity()

    target:AddNewModifier(hero, self, "modifier_lc_w_shield", { duration = 2 })
    target:EmitSound("Arena.LC.CastW")
end

function lc_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(lc_w)
