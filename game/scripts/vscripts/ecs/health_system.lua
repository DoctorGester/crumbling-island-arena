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
    local sourceHero = source

    if source then
        if source.hero then
            sourceHero = source.hero
        end

        if sourceHero ~= self then
            hasBlueRune = sourceHero.HasModifier and sourceHero:HasModifier("modifier_rune_blue")
        end
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
        TriggerBlueRune(sourceHero, self)
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

function HealthSystem:Update()
    local modifier = self:FindModifier("modifier_rune_blue")

    if modifier and modifier.lastDecrementedAt ~= nil and modifier.lastDecrementedAt ~= GameRules:GetGameTime() then
        modifier.lastDecrementedAt = nil
        modifier:DecrementStackCount()

        if modifier:GetStackCount() == 0 then
            modifier:Destroy()
        end
    end
end

function TriggerBlueRune(source, target)
    local modifier = source:FindModifier("modifier_rune_blue")

    FX("particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf", PATTACH_ABSORIGIN_FOLLOW, self, {
        cp1 = source:GetPos(),
        release = true
    })

    target:EmitSound("Arena.RuneBlueHit")
    target:AddNewModifier(target, nil, "modifier_stunned_lua", { duration = 0.6 })
    target.round.spells:InterruptDashes(target)

    if modifier.lastDecrementedAt ~= GameRules:GetGameTime() then
        modifier.lastDecrementedAt = GameRules:GetGameTime()
    end
end