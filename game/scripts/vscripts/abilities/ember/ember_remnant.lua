EmberRemnant = class({}, nil, UnitEntity)

function EmberRemnant:constructor(round, owner, target, ability)
    getbase(EmberRemnant).constructor(self, round, "hero_ember_spirit", owner:GetPos(), owner.unit:GetTeamNumber())

    self.owner = owner.owner
    self.hero = owner
    self.health = 1
    self.size = 64
    self.collisionType = COLLISION_TYPE_RECEIVER

    local unit = self:GetUnit()
    
    if owner.owner then
        unit:SetControllableByPlayer(owner.owner.id, true)
    end

    unit:FindAbilityByName("ember_q"):SetLevel(1)
    unit:FindAbilityByName("ember_w"):SetLevel(1)
    unit:FindAbilityByName("ember_e"):SetLevel(1)
    unit.hero = self

    self:AddNewModifier(self.hero, ability, "modifier_ember_r", { duration = 6 })
    self:SetPos(self.hero:GetPos())

    Dash(self, target, 1800, {
        modifier = { name = "modifier_ember_e", ability = self },
        forceFacing = true,
        arrivalFunction = function()
            self:AddNewModifier(self.hero, ability, "modifier_ember_r_visual", {})
        end
    })

    self:EmitSound("Arena.Ember.CastE")
end

function EmberRemnant:IsInvulnerable()
    return self.invulnerable or self:HasModifier("modifier_ember_e")
end

function EmberRemnant:IsBurning(target)
    return target:HasModifier("modifier_ember_burning")
end

function EmberRemnant:Burn(target, ability)
    if self:IsBurning(target) then
        target:RemoveModifier("modifier_ember_burning")
        return true
    end

    target:AddNewModifier(self, ability, "modifier_ember_burning", { duration = 2.0 })
    return false
end

function EmberRemnant:Damage(source)
    if source.owner.team ~= self.hero.team then
        self.health = self.health - 1
    end

    if self.health == 0 then
        self:Destroy()
    end
end

function EmberRemnant:CollidesWith(source)
    return true
end