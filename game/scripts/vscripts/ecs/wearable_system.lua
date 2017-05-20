WearableSystem = WearableSystem or System("wearables")

function WearableSystem:Update()
    local invisLevel = 0.0
    local modelChanged = self:HasModelChanged()
    local statusFx = self:FindCurrentEffect("GetStatusEffectName", "StatusEffectPriority")
    local heroFx = self:FindCurrentEffect("GetHeroEffectName", "HeroEffectPriority")

    for _, modifier in pairs(self:AllModifiers()) do
        if modifier.GetModifierInvisibilityLevel then
            invisLevel = math.max(invisLevel, math.min(modifier:GetModifierInvisibilityLevel(), 1.0))
        end
    end

    if self.hideQueue ~= nil then
        for _, wearable in pairs(self.wearables) do
            if self.hideQueue then
                wearable:AddNoDraw()
            else
                wearable:RemoveNoDraw()
            end
        end

        self.hideQueue = nil
    end


    local statusFxChanged = self.lastStatusFx ~= statusFx
    self.lastStatusFx = statusFx

    local heroFxChanged = self.lastHeroFx ~= heroFx
    self.lastHeroFx = heroFx

    for _, wearable in pairs(self.wearables) do
        local visuals = wearable:FindModifierByName("modifier_wearable_visuals")

        if visuals then
            local count = invisLevel * 100

            if modelChanged then
                count = count + 101
            end

            visuals:SetStackCount(count)
        end

        if statusFxChanged then
            self:UpdateEffect(wearable, statusFx, "modifier_wearable_visuals_status_fx")
        end

        if heroFxChanged then
            self:UpdateEffect(wearable, heroFx, "modifier_wearable_visuals_hero_fx")
        end
    end
end


function WearableSystem:SetHidden(hidden)
    self.hideQueue = hidden
end

function WearableSystem:Remove()
    self:CleanWearables()
    self:CleanParticles()
end