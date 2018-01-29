Wrappers = {}

function Wrappers.DirectionalAbility(ability, optionalRange, optionalMinRange)
    function ability:GetCastRange()
        return 0
    end

    local getCursorPosition = ability.BaseClass.GetCursorPosition

    function ability:GetDirection()
        local target = getCursorPosition(ability)
        local casterPos = self:GetCaster():GetAbsOrigin()
        local direction = ((target - casterPos) * Vector(1, 1, 0)):Normalized()

        if direction:Length2D() == 0 then
            direction = self:GetCaster():GetForwardVector()
        end

        return direction
    end

    function ability:GetCursorPosition()
        local optionalRangeAsNumber = type(optionalRange) == "function" and optionalRange(self) or optionalRange
        local target = getCursorPosition(ability)
        local realRange = optionalRangeAsNumber or self.BaseClass.GetCastRange(self, target, nil)
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
    local onChannelThink = ability.OnChannelThink

    function ability:OnChannelThink(interval)
        if interval == 0 then
            local function updateLastFacing(self, from)
                local delta = from - self:GetCaster():GetParentEntity():GetPos()
                delta = (delta * Vector(1, 1, 0)):Normalized()

                if delta:Length2D() == 0 then
                    delta = self:GetCaster():GetForwardVector()
                end

                self.lastFacing = delta
                self.lastGuidedPos = from

                self:GetCaster():SetCursorPosition(self.lastGuidedPos)
            end

            updateLastFacing(self, self.BaseClass.GetCursorPosition(self))

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
            local hero = self:GetCaster():GetParentEntity()

            if (hero:GetFacing() - self.lastFacing):Length2D() ~= 0 then
                hero:SetFacing(self.lastFacing)
            end
        end

        if onChannelThink then
            onChannelThink(self, interval)
        end
    end

    local onChannelFinish = ability.OnChannelFinish

    function ability:OnChannelFinish(interrupted)
        if self.listener then
            CustomGameEventManager:UnregisterListener(self.listener)
        end

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

        if onChannelFinish then
            onChannelFinish(self, interrupted)
        end
    end

    function ability:GetCursorPosition()
        return self.lastGuidedPos
    end

    function ability:GetDirection()
        local casterPos = self:GetCaster():GetAbsOrigin()
        local direction = (self.lastGuidedPos - casterPos):Normalized() * Vector(1, 1, 0)

        if direction:Length2D() == 0 then
            direction = self:GetCaster():GetForwardVector()
        end

        return direction
    end
end

function Wrappers.AttackAbility(ability, staticDurationOffset, fx)
    staticDurationOffset = staticDurationOffset or 0

    local getCooldown = ability.GetCooldown
    local onSpellStart = ability.OnSpellStart

    function ability:CastFilterResultLocation(loc)
        if self:GetCaster():IsDisarmed() then
            return UF_FAIL_CUSTOM
        end

        return UF_SUCCESS
    end

    function ability:GetCustomCastErrorLocation(loc)
        if self:GetCaster():IsDisarmed() then
            return "dota_hud_error_unit_disarmed"
        end

        return ""
    end

    function ability:GetCooldown(level)
        local cd = getCooldown and getCooldown(self, level) or self.BaseClass.GetCooldown(self, level)
        local stackCount = self:GetCaster():GetModifierStackCount("modifier_attack_speed", self:GetCaster())

        if stackCount > 2 then
            return cd + cd * 0.4 * stackCount
        end

        return cd
    end

    if IsServer() then
        if fx then
            local onPhaseStart = ability.OnAbilityPhaseStart

            function ability:OnAbilityPhaseStart()
                FX(fx, PATTACH_ABSORIGIN, self:GetCaster():GetParentEntity(), { release = true })

                if onPhaseStart then
                    return onPhaseStart(self)
                end

                return true
            end
        end

        function ability:OnSpellStart()
            local hero = self:GetCaster():GetParentEntity()
            local m = hero:FindModifier("modifier_attack_speed")
            local cd = self:GetCooldown(1)
            local duration = cd * 1.9 + staticDurationOffset

            if false then
                if not m then
                    m = hero:AddNewModifier(hero, self, "modifier_attack_speed", { duration = duration })
                    m:SetStackCount(1)
                else
                    if m:GetStackCount() < 4 then
                        m:IncrementStackCount()
                    end

                    m:SetDuration(duration, true)
                end
            end

            onSpellStart(self)
        end
    end
end

function IsUnitSilenced(hero)
    local silenceModifiers = {
        "modifier_silence_lua",
        "modifier_am_r",
        "modifier_sven_w_slow",
        "modifier_ogre_5",
        "modifier_ogre_6",
        "modifier_falling"
    }

    for _, mod in ipairs(silenceModifiers) do
        if hero:HasModifier(mod) then
            return true
        end
    end

    return false
end

function IsFullyCastable(ability, location)
    local passesFilters = true

    if location and ability.CastFilterResultLocation then
        passesFilters = passesFilters and ability:CastFilterResultLocation(location) == UF_SUCCESS
    end

    if ability.CastFilterResult then
        passesFilters = passesFilters and ability:CastFilterResult() == UF_SUCCESS
    end

    return ability:IsFullyCastable() and not IsUnitSilenced(ability:GetCaster()) and passesFilters
end

function Wrappers.NormalAbility(ability)
    local getBehavior = ability.GetBehavior
    local castFilterResult = ability.CastFilterResult or function() return UF_SUCCESS end
    local castError = ability.GetCustomCastError or function() return "" end

    ability.canBeSilenced = true

    function ability:GetBehavior()
        if IsUnitSilenced(self:GetCaster()) then
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET
        end

        if getBehavior then
            return getBehavior(self)
        end

        return self.BaseClass.GetBehavior(self)
    end

    function ability:CastFilterResult()
        if IsUnitSilenced(self:GetCaster()) then
            return UF_FAIL_CUSTOM
        end

        return castFilterResult(self)
    end

    function ability:GetCustomCastError()
        if IsUnitSilenced(self:GetCaster()) then
            return "#dota_hud_error_unit_silenced"
        end

        return castError(self)
    end
end

function Wrappers.WrapAbilitiesFromHeroData(unit, data)
    local count = unit:GetAbilityCount() - 1
    for i = 0, count do
        local ability = unit:GetAbilityByIndex(i)

        if ability ~= nil then
            for _, abilityName in pairs((data or {}).abilities or {}) do
                local abilityData = GameRules.GameMode.AllAbilities[abilityName] or {}

                if abilityData.name == ability:GetName() and abilityData.damage then
                    ability.GetDamage = function(a)
                        return abilityData.damage
                    end

                    break
                end
            end
        end
    end
end