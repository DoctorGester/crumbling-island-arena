DUMMY_UNIT = "npc_dummy_unit"

Spells = Spells or class({})

function Spells:constructor()
    self.entities = {}
    self.dashes = {}
end

function Spells:Update()
    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]

        if entity.destroyed then
            entity:Remove()
            table.remove(self.entities, i)
        end
    end

    for i = #self.dashes, 1, -1 do
        local dash = self.dashes[i]

        dash:Update()

        if dash.destroyed then
            table.remove(self.dashes, i)
        end
    end

    for _, entity in ipairs(self.entities) do
        entity:Update()
    end

    -- resolving collisions
    -- TODO add segment/circle and segment/segment resolvers
    -- TODO add projectile destroy effect
    --[[
        local between = projectile.position + (second.position - projectile.position) / 2
        Spells:ProjectileDestroyEffect(between + Vector(0, 0, 64))
    ]]--

    for _, first in ipairs(self.entities) do
        if first:Alive() and first.collisionType == COLLISION_TYPE_INFLICTOR then
            for _, second in ipairs(self:GetValidTargets()) do
                if first ~= second and second.collisionType ~= COLLISION_TYPE_NONE and first:CollidesWith(second) and second:CollidesWith(first) then
                    local radSum = first:GetRad() + second:GetRad()

                    if (first:GetPos() - second:GetPos()):Length2D() <= radSum then
                        first:CollideWith(second)
                        second:CollideWith(first)
                    end
                end
            end
        end
    end
end

function Spells:GroundDamage(point, radius)
    GameRules.GameMode.level:DamageGroundInRadius(point, radius)
end

function Spells:ProjectileDestroyEffect(owner, pos)
    ImmediateEffectPoint("particles/ui/ui_generic_treasure_impact.vpcf", PATTACH_ABSORIGIN, GameRules:GetGameModeEntity(), pos)
    local deny = ImmediateEffectPoint("particles/msg_fx/msg_deny.vpcf", PATTACH_CUSTOMORIGIN, GameRules:GetGameModeEntity(), pos)
    ParticleManager:SetParticleControl(deny, 3, Vector(200, 0, 0))
end

function Spells:GetValidTargets()
    local result = {}

    for _, ent in pairs(self.entities) do
        if not ent.invulnerable and ent:Alive() then
            table.insert(result, ent)
        end
    end

    return result
end

function Spells:GetHeroTargets()
    local result = {}

    for _, ent in pairs(self:GetValidTargets()) do
        if ent:__instanceof__(Hero) then
            table.insert(result, ent)
        end
    end

    return result
end

function Spells:AddDash(dash)
    table.insert(self.dashes, dash)
end

function Spells:AddDynamicEntity(entity)
    table.insert(self.entities, entity)
end