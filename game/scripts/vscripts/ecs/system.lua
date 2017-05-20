System = System or class({})

function System:constructor(...)
    self.required = {}

    for _, requirement in ipairs({...}) do
        table.insert(self.required, requirement)
    end
end

function System:FilterEntity(entity)
    for _, requirement in ipairs(self.required) do
        if entity[requirement] == nil then
            return false
        end
    end

    return true
end

function System:FilterEntities(list)
    local filtered = {}

    for _, entity in ipairs(list) do
        if self:FilterEntity(entity) then
            table.insert(filtered, entity)
        end
    end

    return filtered
end

function System:EntityCall(entityList, method, ...)
    if self[method] then
        for _, entity in ipairs(self:FilterEntities(entityList)) do
            self[method](entity, ...)
        end
    end
end