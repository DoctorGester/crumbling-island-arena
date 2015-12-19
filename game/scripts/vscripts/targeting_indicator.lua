if not TargetingIndicator then
    TargetingIndicator = class({})
end

function TargetingIndicator:Load()
    local kv = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
    local targetingIndicators = {}
    local hoverIndicators = {}

    for key, ability in pairs(kv) do
        if ability.TargetingIndicator then
            targetingIndicators[key] = ability.TargetingIndicator
        end

        if ability.HoverIndicator then
            hoverIndicators[key] = ability.HoverIndicator
        end
    end

    CustomNetTables:SetTableValue("main", "targetingIndicators", targetingIndicators)
    CustomNetTables:SetTableValue("main", "hoverIndicators", hoverIndicators)
end

TargetingIndicator:Load()