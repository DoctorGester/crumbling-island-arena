storm_spirit_w = class({})

function storm_spirit_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local remnant = hero:FindClosestRemnant(target)

    if remnant then
        hero:AreaEffect({
            filter = Filters.Area(remnant:GetPos(), 300),
            filterProjectiles = true,
            damage = true
        })

        remnant:Destroy()
    end
end

function storm_spirit_w:CastFilterResultLocation(location)
    -- Remnant data can't be accessed on the client
    if not IsServer() then return UF_SUCCESS end

    if not self:GetCaster().hero:HasRemnants() then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function storm_spirit_w:GetCustomCastErrorLocation(location)
    if not IsServer() then return "" end

    if not self:GetCaster().hero:HasRemnants() then
        return "#dota_hud_error_cant_cast_no_remnants"
    end

    return ""
end