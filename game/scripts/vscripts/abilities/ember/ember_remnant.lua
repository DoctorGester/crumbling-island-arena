EmberRemnant = class({}, nil, WearableOwner)

function EmberRemnant:constructor(round, owner, target, ability)
    getbase(EmberRemnant).constructor(self, round, "ember_remnant", owner:GetPos(), owner.unit:GetTeamNumber(), false, owner.owner)

    self.owner = owner.owner
    self.hero = owner
    self.health = 1
    self.size = 64
    self.collisionType = COLLISION_TYPE_RECEIVER

    local unit = self:GetUnit()
    
    if owner.owner then
        unit:SetControllableByPlayer(owner.owner.id, true)
    end

    unit:AddAbility("ember_q"):SetLevel(1)
    unit:AddAbility("ember_w"):SetLevel(1)
    unit:AddAbility("ember_e"):SetLevel(1)
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
    self:SetCustomHealth(2)
    self:EnableHealthBar()
    self:LoadItems(unpack(owner:BuildWearableStack()))

    Wrappers.WrapAbilitiesFromHeroData(unit, self.hero.data)
end

function EmberRemnant:GetName()
    return "npc_dota_hero_ember_spirit"
end

function EmberRemnant:IsInvulnerable()
    return self.invulnerable or self:HasModifier("modifier_ember_e")
end

function EmberRemnant:CollidesWith(source)
    return true
end