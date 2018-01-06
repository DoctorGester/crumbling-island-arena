HealthSystem = HealthSystem or System("customHealth", "healthBarEnabled")

function HealthSystem:Damage(source, amount, isPhysical)
    if amount == nil then
        amount = 3
    end

    if source == nil then source = self end

    if not self:Alive() or self.protected or self.falling then
        return
    end

    if self:IsInvulnerable() and source ~= self then
        return
    end

    local all = self:AllModifiers()

    table.insert(all, self) -- To be able to declare OnDamageReceived and OnDamageReceivedPriority on the entity itself

    table.sort(all, function(a, b)
        local ap = a.OnDamageReceivedPriority and a:OnDamageReceivedPriority() or 0
        local bp = b.OnDamageReceivedPriority and b:OnDamageReceivedPriority() or 0

        return ap > bp
    end)

    for _, modifier in pairs(all) do
        if modifier.OnDamageReceived then
            local result = modifier:OnDamageReceived(source, self, amount, isPhysical)

            if result == false then -- == false so nil works
                return
            end

            if result ~= true then
                local prevAmount = amount
                amount = result or amount;

                -- Never amplify self damage
                if source == self then
                    amount = math.min(amount, prevAmount)
                end
            end
        end
    end

    local hasBlueRune = false

    if source then
        local sourceHero = source

        if source.hero then
            sourceHero = source.hero
        end

        hasBlueRune = sourceHero.HasModifier and sourceHero:HasModifier("modifier_rune_blue")
    end

    if self.customHealth then
        self.health = math.max(0, self.health - amount)

        if self.health <= 0 then
            self:Destroy()
        elseif self.healthBarEnabled then
            self:GetUnit():SetHealth(self.health)
        end
    else
        local damageTable = {
            victim = self.unit,
            attacker = source.unit,
            damage = amount,
            damage_type = DAMAGE_TYPE_PURE,
        }

        ApplyDamage(damageTable)
    end

    GameRules.GameMode:OnDamageDealt(self, source, amount)

    if amount > 0 and hasBlueRune then
        FX("particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf", PATTACH_ABSORIGIN_FOLLOW, self, {
            cp1 = source:GetPos(),
            release = true
        })

        self:EmitSound("Arena.RuneBlueHit")
        self:GetUnit():AddNewModifier(self:GetUnit(), nil, "modifier_stunned", { duration = 0.8 })
    end

    self:GetUnit():AddNewModifier(self:GetUnit(), nil, "modifier_damaged", { duration = 0.2 })

    local color = isPhysical and Vector(250, 70, 70) or Vector(100, 130, 240)

    FX("particles/msg_damage.vpcf", PATTACH_CUSTOMORIGIN, GameRules:GetGameModeEntity(), {
        cp0 = self:GetPos(),
        cp1 = Vector(0, amount, 0),
        cp2 = Vector(math.max(1, amount / 1.5), 1, 0),
        cp3 = color,
        release = true
    })

    if source then
        for _, entity in pairs(source.round.spells.entities) do
            if entity:Alive() then
                for _, modifier in pairs(entity:AllModifiers()) do
                    if modifier.OnDamageDealt then
                        modifier:OnDamageDealt(self, source, amount, isPhysical)
                    end
                end
            end
        end
    end

    if not self:Alive() and self.OnDeath then
        self:OnDeath(source)
    end
end