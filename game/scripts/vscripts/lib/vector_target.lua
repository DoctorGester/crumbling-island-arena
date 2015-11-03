--[[
    AUTHOR: Adam Curtis, Copyright 2015
    CONTACT: kallisti.dev@gmail.com
    WEBSITE: https://github.com/kallisti-dev/vector_target
    LICENSE: https://github.com/kallisti-dev/vector_target/blob/master/LICENSE
--]]

DEFAULT_VECTOR_TARGET_PARTICLE = "particles/vector_target/vector_target_range_finder_line.vpcf"
DEFAULT_VECTOR_TARGET_CONTROL_POINTS = {
    [0] = "initial",
    [1] = "initial",
    [2] = "terminal"
}

--[[
VECTOR_TARGET_DEBUG_NONE = 0     -- no logging
VECTOR_TARGET_DEBUG_DEFAULT = 1  -- default logging of important events
VECTOR_TARGET_DEBUG_ALL = 2      -- detailed debug info
]]
local reloading = false
if VectorTarget == nil then
    VectorTarget = {
        inProgressOrders = { }, -- a table of vector orders currently in-progress, indexed by player ID
        abilityKeys = { }, -- data loaded from KV files, indexed by ability name
        kvSources = { }, -- a list of filenames / tables that were passed to LoadKV, used during reloading
        castQueues = { }, -- table of cast queues indexed by castQueues[unit ID][ability ID]
        userIds = { } -- user id -> player id
        --debugMode = VECTOR_TARGET_DEBUG_ALL, -- debug output mode
    }
else
    reloading = true
end

VectorTarget.VERSION = {0,2,3};

local queue = class({}) -- sparse queue implementation (see bottom of file for code)

-- call this in your Precache() function to precache vector targeting particles
function VectorTarget:Precache(context)
    if self.initializedPrecache then return end
    print("[VECTORTARGET] precaching assets")
    --PrecacheResource("particle", "particles/vector_target_ring.vpcf", context)
    PrecacheResource("particle", "particles/vector_target/vector_target_range_finder_line.vpcf", context)
    self.initializedPrecache = true
end


-- call this in your init function to initialize for default use-case behavior
function VectorTarget:Init(opts)
    print("[VECTORTARGET] initializing")
    if not self.initializedPrecache then
        print("[VECTORTARGET] warning: VectorTarget:Precache was not called before Init.")
    end
    opts = opts or { }
    if not opts.noEventListeners then
        self:InitEventListeners()
    end
    if not opts.noOrderFilter then
        self:InitOrderFilter()
    end
    if opts.kvList ~= false then
        self:LoadKV(opts.kvList or {"scripts/npc/npc_abilities_custom.txt", "scripts/npc/npc_items_custom.txt"})
    end
    self.debugMode = opts.debug or self.debugMode
end

-- call this in your init function to start listening to events
function VectorTarget:InitEventListeners()
    if self.initializedEventListeners then return end
    print("[VECTORTARGET] registering event listeners")
    -- Note: wrapping the calls in an anonymous function allows reloading to work properly
    --ListenToGameEvent("npc_spawned", function(...) self:_OnNpcSpawned(...) end, {})
    CustomGameEventManager:RegisterListener("vector_target_order_cancel", function(...) self:_OnVectorTargetOrderCancel(...) end)
    CustomGameEventManager:RegisterListener("vector_target_queue_full", function(...) self:_OnVectorTargetQueueFull(...) end)
    --ListenToGameEvent('player_connect_full', Dynamic_Wrap(VectorTarget, "_OnPlayerConnectFull"), self)
    self.initializedEventListeners = true
end

-- call this in your init code to initialize the library's SetExecuteOrderFilter
function VectorTarget:InitOrderFilter()
    print("[VECTORTARGET] registering ExecuteOrderFilter (use noOrderFilter option to prevent this)")
    local mode = GameRules:GetGameModeEntity()
    mode:ClearExecuteOrderFilter()
    mode:SetExecuteOrderFilter(function(_, data) return self:OrderFilter(data) end, {}) -- Note: wrapping the call in an anonymous function allows reloading to work properly
    self.initializedOrderFilter = true
end

-- Loads vector target KV values from a file, or a table with the same format as one returned by LoadKeyValues()
function VectorTarget:LoadKV(kvList, forgetSource)
    for _, kv in ipairs(kvList or { }) do
        local kvFile
        if type(kv) == "string" then
            kvFile = kv
            kv = LoadKeyValues(kvFile)
            if kv == nil then
                error("[VECTORTARGET] Error when loading KV from file: " .. kvFile)
            end
        elseif type(kv) ~= "table" then
            error("[VECTORTARGET] LoadKV: expected string or table but got " .. type(kv) .. ": " .. tostring(kv))
        end
        print("[VECTORTARGET] Loading KV data from: " .. (kvFile or tostring(kv)))
        for name, keys in pairs(kv) do
            if type(keys) == "table" then
                keys = keys["VectorTarget"]
                if keys and keys ~= "false" and keys ~= "0" and (type(keys) ~= "number" or keys ~= 0) then
                    if type(keys) ~= "table" then
                        keys = { }
                    end
                    self.abilityKeys[name] = keys
                end
            else
                print("[VECTORTARGET] Warning: Expected a table for ability definition " .. name .. " but got " .. type(keys) .. " instead.")
            end
        end
        if not forgetSource then
            table.insert(self.kvSources, kvFile or kv)
        end
    end
end

function VectorTarget:ReloadAllKV(deletePrevious)
    --[[ Reloads KV from files/tables passed via VectorTarget:LoadKV

        If the first argument is false, prevents deletion of previous KV data before reloading
    ]]
    if deletePrevious ~= false then
        self.abilityKeys = { }
    end
    self:LoadKV(self.kvSources, true)
end

function VectorTarget:GetInProgressForPlayer(playerId)
    --[[ Retrieves the current in-progress order, if any, for the given player.
    ]]
    return self.inProgressOrders[playerId]
end

function VectorTarget:GetInProgressForUnit(unitId)
    --[[ Gets in-progress orders for current unit.

        Since multiple players could have in-progress orders on the same unit, this method returns an array of orders indexed by issuer's player ID
    ]]
    local out = { }
    for playerId, order in ipairs(self.inProgressOrders) do
        if order.unitId == unitId then
            out[playerId] = order
        end
    end
    return out
end

function VectorTarget:GetInProgressForAbility(abilId)
    --[[ Gets in-progress orders for current ability.

        Since multiple players could have in-progress orders on the same unit, this method returns an array of orders indexed by issuer's player ID.
    ]]
    local out = { }
    for playerId, order in ipairs(self.inProgressOrders) do
        if order.abilId == abilId then
            out[playerId] = order
        end
    end
    return out
end

-- get the cast queue for a given (unit, ability) pair
function VectorTarget:GetCastQueue(unitId, abilId)
    local queues = self.castQueues
    local unitTable = queues[unitId]
    if not unitTable then
        unitTable = { }
        queues[unitId] = unitTable
    end
    local q = unitTable[abilId]
    if not q then
        q = queue()
        unitTable[abilId] = q
    end
    return q
end

-- given an array of unit ids, clear all cast queues associated with those units
function VectorTarget:ClearQueuesForUnits(units)
    for _, unitId in pairs(units) do
        for _, q in pairs(self.castQueues[unitId] or { }) do
            if q then
                q:clear()
            end
        end
    end
end

-- get the largest sequence number for vector target orders issued on this unit
function VectorTarget:GetMaxSequenceNumber(unitId)
    local out = -1
    for _, q in pairs(self.castQueues[unitId] or { }) do
        if q and q.last > out then
            out = q.last
        end
    end
    return out
end

-- call this on a unit to add vector target functionality to its abilities
function VectorTarget:WrapUnit(unit)
    for i=0, unit:GetAbilityCount()-1 do
        local abil = unit:GetAbilityByIndex(i)
        if abil ~= nil then
            self:WrapAbility(abil)
        end
    end
end

--wrapper applied to all vector targeted abilities during initialization
function VectorTarget:WrapAbility(abil, reloading)
    local keys = self.abilityKeys[abil:GetAbilityName()]
    if keys == nil then -- no VectorTarget block
        return
    end
    local VectorTarget = self
    local abiName = abil:GetAbilityName()
    local cName = abil:GetClassname()
    if "ability_lua" ~= cName and "item_lua" ~= cName then
        print("[VECTORTARGET] Warning: " .. abiName .. " is not a Lua ability/item and cannot be vector targeted.")
        return
    end
    if not reloading and abil.isVectorTarget then
        return
    end

    --initialize members
    abil.isVectorTarget = true -- use this to test if an ability has vector targeting
    abil._vectorTargetKeys = {
        initialPosition = nil,                      -- initial position of vector input
        terminalPosition = nil,                     -- terminal position of vector input
        minDistance = keys.MinDistance,
        maxDistance = keys.MaxDistance,
        pointOfCast = keys.PointOfCast or "initial",
        particleName = keys.ParticleName or DEFAULT_VECTOR_TARGET_PARTICLE,
        cpMap = keys.ControlPoints or DEFAULT_VECTOR_TARGET_CONTROL_POINTS
    }

    function abil:GetInitialPosition()
        return self._vectorTargetKeys.initialPosition
    end

    function abil:SetInitialPosition(v)
        if type(v) == "table" then
            v = Vector(v.x, v.y, v.z)
        end
        self._vectorTargetKeys.initialPosition = v
    end

    function abil:GetTerminalPosition()
        return self._vectorTargetKeys.terminalPosition
    end

    function abil:SetTerminalPosition(v)
        if type(v) == "table" then
            v = Vector(v.x, v.y, v.z)
        end
        self._vectorTargetKeys.terminalPosition = v
    end

    function abil:GetMidpointPosition()
        return VectorTarget._CalcMidPoint(self:GetInitialPosition(), self:GetTerminalPosition())
    end

    function abil:GetTargetVector()
        local i = self:GetInitialPosition()
        local j = self:GetTerminalPosition()
        return Vector(j.x - i.x, j.y - i.y, j.z - i.z)
    end


    function abil:GetDirectionVector()
        return self:GetTargetVector():Normalized()
    end

    if not abil.GetMinDistance then
        function abil:GetMinDistance()
            return self._vectorTargetKeys.minDistance
        end
    end

    if not abil.GetMaxDistance then
        function abil:GetMaxDistance()
            return self._vectorTargetKeys.maxDistance
        end
    end

    if not abil.GetPointOfCast then
        function abil:GetPointOfCast()
            return VectorTarget._CalcPointOfCast(abil._vectorTargetKeys.pointOfCast, abil:GetInitialPosition(), abil:GetTerminalPosition())
        end
    end

    if not abil.GetVectorTargetParticleName then
        function abil:GetVectorTargetParticleName()
            return self._vectorTargetKeys.particleName
        end
    end

    if not abil.GetVectorTargetControlPointMap then
        function abil:GetVectorTargetControlPointMap()
            return self._vectorTargetKeys.cpMap
        end
    end

    --override GetBehavior
    local _GetBehavior = abil.GetBehavior
    function abil:GetBehavior()
        local b = _GetBehavior(self)
        return bit.bor(b, DOTA_ABILITY_BEHAVIOR_POINT)
    end

    --override OnAbilityPhaseStart
    local _OnAbilityPhaseStart = abil.OnAbilityPhaseStart
    function abil:OnAbilityPhaseStart()
        if not reloading then
            local abilId = self:GetEntityIndex()
            local unitId = self:GetCaster():GetEntityIndex()
            local data = VectorTarget:GetCastQueue(unitId, abilId):popFirst()
            self:SetInitialPosition(data.initialPosition)
            self:SetTerminalPosition(data.terminalPosition)
        end
        return _OnAbilityPhaseStart(self)
    end

    --override CastFilterResultLocation
    local _CastFilterResultLocation = abil.CastFilterResultLocation
    function abil:CastFilterResultLocation(location)
        return VectorTarget:_CastFilterHelper(self, _CastFilterResultLocation, location)
    end

    --override GetCustomCastErrorLocation
    local _GetCustomCastErrorLocation = abil.GetCustomCastErrorLocation
    function abil:GetCustomCastErrorLocation(location)
        local msg = _GetCustomCastErrorLocation(self, location)
        if (not msg or msg == "" or msg == "CUSTOM ERROR") and self.GetCustomCastErrorVector then
            msg = self:GetCustomCastErrorVector(self._vectorTargetKeys.castFilterData)
        end
        return msg
    end
end

function VectorTarget:OrderFilter(data)
    --util.printTable(data)
    local playerId = data.issuer_player_id_const
    local abilId = data.entindex_ability
    local inProgress = self.inProgressOrders[playerId] -- retrieve any in-progress orders for this player
    local seqNum = data.sequence_number_const
    local units = { }
    local nUnits = 0
    for i, unitId in pairs(data.units) do
        if seqNum > self:GetMaxSequenceNumber(unitId) then
            units[i] = unitId
            nUnits = nUnits + 1
        end
    end
    if nUnits == 0 then
        return true
    end
    --print("seq num: ", seqNum, "order type: ", data.order_type, "queue: ", data.queue)
    if abilId ~= nil and abilId > 0 then
        local abil = EntIndexToHScript(abilId)
        if abil ~= nil then
            self:WrapAbility(abil)
            if abil.isVectorTarget and data.order_type == DOTA_UNIT_ORDER_CAST_POSITION then
                local unitId = units["0"] or units[0]
                local targetPos = {x = data.position_x, y = data.position_y, z = data.position_z}
                if inProgress == nil or inProgress.abilId ~= abilId or inProgress.unitId ~= unitId then -- if no in-progress order, this order selects the initial point of a vector cast
                    --print("inProgress", playerId, abilId, unitId)
                    local orderData = {
                        initialPosition = targetPos,
                        minDistance = abil:GetMinDistance(),
                        maxDistance = abil:GetMaxDistance(),
                        cpMap = abil._vectorTargetKeys.cpMap,
                        particleName = abil._vectorTargetKeys.particleName,
                        seqNum = seqNum,
                        abilId = abilId,
                        time = Time(),
                        orderType = data.order_type,
                        unitId = unitId,
                        shiftPressed = data.queue,
                    }
                    self.inProgressOrders[playerId] = orderData --set this order as our player's current in-progress order
                    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "vector_target_order_start", orderData)
                    return false
                else --in-progress order (initial point has been selected)
                    if inProgress.shiftPressed == 1 then --make this order shift-queued if previous order was
                        data.queue = 1
                    elseif data.queue == 0 then -- if not shift queued, clear cast queue before we add to it
                        self:ClearQueuesForUnits(units)
                    end

                    inProgress.terminalPosition = targetPos

                    --temporarily set initial/terminal on the ability so we can all (a possibly overriden) abil:GetPointOfCast
                    local p = VectorTarget._WithPoints(abil, inProgress.initialPosition, inProgress.terminalPosition, function()
                            return abil:GetPointOfCast()
                    end)
                    data.position_x = p.x
                    data.position_y = p.y
                    data.position_z = p.z
                    self:GetCastQueue(unitId, abilId):push(inProgress, seqNum)
                    self.inProgressOrders[playerId] = nil
                    -- something in the inProgress table causes the event system to crash the game, so we need to make a new table and pick out
                    -- only the important values.
                    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "vector_target_order_finish", {
                        --terminalPosition = inProgress.initialPosition,
                        --initialPosition = inProgress.terminalPosition,
                        unitId = inProgress.unitId,
                        abilId = inProgress.abilId,
                        seqNum = inProgress.seqNum,
                    })
                    return true -- exit early
                end
            end
        end
    end
    if data.queue == 0 then -- if shift was not pressed, clear our cast queues for the unit(s) in question
        self:ClearQueuesForUnits(units)
    end
    if inProgress ~= nil then
        self.inProgressOrders[playerId] = nil
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "vector_target_order_cancel", inProgress)
    end
    return true
end

--[[ Library Event Handlers ]]

function VectorTarget:_OnVectorTargetOrderCancel(eventSource, keys)
    local pId = eventSource - 1
    local inProgress = self.inProgressOrders[pId]
    if inProgress ~= nil and inProgress.seqNum == keys.seqNum then
        --print("canceling")
        self.inProgressOrders[pId] = nil
    end
end

function VectorTarget:_OnVectorTargetQueueFull(eventSource, keys)
    --print("queue full")
    --util.printTable(keys)
end

--[[
function VectorTarget:_OnPlayerConnectFull(keys)
    local p = EntIndexToHScript(keys.index + 1)
    self.userIds[keys.index] = p:GetPlayerID()
end
]]

--[[
function VectorTarget:_OnNpcSpawned(ctx, keys)
    self:WrapUnit(EntIndexToHScript(keys.entindex))
end
]]

function VectorTarget:_OnScriptReload()
    VectorTarget:ReloadAllKV()
    --reload existing abilities
    for _, ents in ipairs({Entities:FindAllByClassname("ability_lua"), Entities:FindAllByClassname("item_lua")}) do
        for _, abil in pairs(ents) do
            self:WrapAbility(abil, true)
        end
    end
end

--[[ Internal Helper/Utility Functions ]]

function VectorTarget._CalcPointOfCast(mode, initial, terminal)
    if mode == "initial" then
        return initial
    elseif mode == "terminal" then
        return terminal
    elseif mode == "midpoint" then
        return VectorTarget._CalcMidPoint(initial, terminal)
    else
        error("[VECTORTARGET] invalid point-of-cast mode: " .. string(mode))
    end
end

function VectorTarget._CalcMidPoint(a, b)
    return Vector((a.x + b.x)/2, (a.y + b.y)/2, (a.z + b.z)/2)
end

-- helper to temporarily set targeting information
function VectorTarget._WithPoints(abil, initial, terminal, func, ...)
    local initialOld, terminalOld = abil:GetInitialPosition(), abil:GetTerminalPosition()
    abil:SetInitialPosition(initial)
    abil:SetTerminalPosition(terminal)
    local status, res = pcall(func, ...)
    abil:SetInitialPosition(initialOld)
    abil:SetTerminalPosition(terminalOld)
    if status then
        return res
    else
        error(res)
    end
end

function VectorTarget:_CastFilterHelper(abil, parentMethod, ...)
    local abilId = abil:GetEntityIndex()
    local unitId = abil:GetCaster():GetEntityIndex()
    --[[
    --check in-progress orders
    local orders = self:GetInProgressForAbility(abilId)
    local inProgress
    for playerId, order in pairs(orders) do -- find oldest in-progress order for this unit with an unhandled cast filter
        if not order.castFilterHandled and order.unitId == unitId and (inProgress == nil or inProgress.time >= order.time) then
            inProgress = order
        end
    end
    local data, method
    if inProgress ~= nil then --handle in-progress order
        data = inProgress
        method = abil.CastFilterResultVectorStart or abil.CastFilterResultVector
        data.castFilterHandled = true
    else -- handle completed order
    --]]
    local data = VectorTarget:GetCastQueue(unitId, abilId):peekLast()
    local method = abil.CastFilterResultVectorFinish or abil.CastFilterResultVector
    abil._vectorTargetKeys.castFilterData = data
    --setup ability state
    abil:SetInitialPosition(data.initialPosition)
    abil:SetTerminalPosition(data.terminalPosition)
    local status = parentMethod(abil, ...) -- call parent method (CastFilterResultLocation, CastFilterResultTarget, etc)
    if status == UF_SUCCESS and method then -- if successful, call vector target cast filter
        status = method(abil, data)
    end
    return status
end


--[[ A sparse queue implementation ]]
function queue.constructor(q)
    q.first = 0
    q.last = -1
    q.len = 0
end

function queue.push(q, value, seqN)
    --print("push", q.first, q.last, q.len)
    --[[if q:length() >= MAX_ORDER_QUEUE then
        print("[VECTORTARGET] warning: order queue has reached limit of " .. MAX_ORDER_QUEUE)
        return
    end]]
    if seqN == nil then
        seqN = q.last + 1
    end
    q[seqN] = value
    q.len = q.len + 1
    if q.len == 1 then
        q.first = seqN
        q.last = seqN
    elseif seqN > q.last then
        q.last = seqN
    elseif seqN < q.first then
        q.first = seqN
    end
end

function queue.popLast(q)
    local last = q.last
    if q.first > last then error("queue is empty") end
    local value = q[last]
    q[last] = nil
    q.len = q.len - 1
    for i = last, q.first, -1 do --find new last index
        if q[i] ~= nil then
            q.last = i
            return value
        end
    end
    q.last = q.first - 1 --empty
    return value
end


function queue.popFirst(q)
    --print("pop", q.first, q.last, q.len)
    local first = q.first
    if first > q.last then error("queue is empty") end
    local value = q[first]
    q[first] = nil
    q.len = q.len - 1
    for i = first, q.last do --find new first index
        if q[i] ~= nil then
            q.first = i
            return value
        end
    end
    q.first = q.last + 1 --empty
    return value
end

function queue.clear(q)
    for i = q.first, q.last do
        q[i] = nil
    end
    q.first = 0
    q.last = -1
    q.len = 0
end

function queue.peekLast(q)
    return q[q.last]
end

function queue.peekFirst(q)
    return q[q.first]
end

function queue.length(q)
    return q.len
end

if reloading then
    VectorTarget:_OnScriptReload()
end