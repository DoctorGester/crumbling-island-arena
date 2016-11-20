Wrappers = {}

function Wrappers.DirectionalAbility(ability, optionalRange, optionalMinRange)
    function ability:GetCastRange()
        return 0
    end

    local getCursorPosition = ability.BaseClass.GetCursorPosition

    function ability:GetDirection()
        local target = getCursorPosition(ability)
        local casterPos = self:GetCaster():GetAbsOrigin()
        local direction = (target - casterPos):Normalized() * Vector(1, 1, 0)

        if direction:Length2D() == 0 then
            direction = self:GetCaster():GetForwardVector()
        end

        return direction
    end

    function ability:GetCursorPosition()
        local target = getCursorPosition(ability)
        local realRange = optionalRange or self.BaseClass.GetCastRange(self, target, nil)
        local minRange = optionalMinRange or 0
        local casterPos = self:GetCaster():GetAbsOrigin()
        local direction = self:GetDirection()

        if realRange > 0 and (target - casterPos):Length2D() > realRange then
            target = casterPos + direction * realRange
        end

        if (target - casterPos):Length2D() < minRange then
            target = casterPos + direction * minRange
        end

        return target
    end
end

function Wrappers.GuidedAbility(ability, forceFacing, doNotSetFacing)
    if ability._guided then
        return
    else
        ability._guided = true
    end

    local onChannelThink = ability.OnChannelThink
    local getCursorPosition = ability.GetCursorPosition

    function ability:OnChannelThink(interval)
        if interval == 0 then
            local function updateLastFacing(self, from)
                local delta = from - self:GetCaster():GetParentEntity():GetPos()
                delta = (delta * Vector(1, 1, 0)):Normalized()
                self.lastFacing = delta
                self.lastGuidedPos = from
            end

            updateLastFacing(self, getCursorPosition(self))

            self.listener = CustomGameEventManager:RegisterListener("guided_ability_cursor", function(_, args)
                local eventAbility = EntIndexToHScript(args.ability)

                if eventAbility ~= self or args.PlayerID ~= self:GetCaster():GetParentEntity().owner.id then
                    return
                end

                local pos = Vector(args.pos["0"], args.pos["1"], args.pos["2"])
                updateLastFacing(self, pos)
            end)
        end

        if not doNotSetFacing then
            self:GetCaster():GetParentEntity():SetFacing(self.lastFacing)
        end

        onChannelThink(self, interval)
    end

    local onChannelFinish = ability.OnChannelFinish

    function ability:OnChannelFinish(interrupted)
        CustomGameEventManager:UnregisterListener(self.listener)

        if forceFacing then
            local caster = self:GetCaster()
            local f = caster:GetParentEntity():GetFacing()

            Timers:CreateTimer(function()
                if IsValidEntity(caster) then
                    caster:Interrupt()
                    caster:GetParentEntity():SetFacing(f)
                end
            end)
        end

        onChannelFinish(self, interrupted)
    end

    function ability:GetCursorPosition()
        return self.lastGuidedPos
    end
end

function Wrappers.AttackAbility(ability)
    local getCooldown = ability.GetCooldown
    local onSpellStart = ability.OnSpellStart

    function ability:GetCooldown(level)
        local cd = getCooldown and getCooldown(self, level) or self.BaseClass.GetCooldown(self, level)
        local stackCount = self:GetCaster():GetModifierStackCount("modifier_attack_speed", self:GetCaster())

        if stackCount > 2 then
            return cd + cd * 0.4 * stackCount
        end

        return cd
    end

    if IsServer() then
        function ability:OnSpellStart()
            local hero = self:GetCaster():GetParentEntity()
            local m = hero:FindModifier("modifier_attack_speed")
            local cd = self:GetCooldown(1)
            local duration = cd * 1.75

            if not m then
                m = hero:AddNewModifier(hero, self, "modifier_attack_speed", { duration = duration })
                m:SetStackCount(1)
            else
                m:IncrementStackCount()
                m:SetDuration(duration, true)
            end

            onSpellStart(self)
        end
    end
end