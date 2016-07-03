Stats = Stats or {}

Stats.host = "http://127.0.0.1:3637/"

if IsInToolsMode() then
    local oldGetter = CDOTA_PlayerResource.GetSteamID

    CDOTA_PlayerResource.GetSteamID = function(self, playerId)
        local steamId = oldGetter(self, playerId)

        if tostring(steamId) == "0" then
            return playerId
        end

        return steamId
    end
end

function Stats.SubmitMatchInfo(players, mode, version, callback)
    local data = {}
    data.mode = mode
    data.version = version
    data.players = {}

    for _, player in pairs(players) do
        local playerData = {}
        playerData.steamId64 = tostring(PlayerResource:GetSteamID(player.id))
        playerData.team = player.team

        table.insert(data.players, playerData)
    end

    Stats.SendData(string.format("match/%s", GameRules:GetMatchID()), data, callback)
end

function Stats.SubmitRoundInfo(players, roundNumber, roundWinner, statistics)
    local data = {}

    data.winner = roundWinner
    data.players = {}

    for _, player in pairs(players) do
        local stats = statistics.stats[player.id]
        local playerData = {}
        playerData.steamId64 = tostring(PlayerResource:GetSteamID(player.id))
        playerData.damageDealt = stats.damageDealt or 0
        playerData.projectilesFired = stats.projectilesFired or 0
        playerData.score = player.score
        playerData.hero = player.selectedHero
        playerData.connectionState = PlayerResource:GetConnectionState(player.id)

        table.insert(data.players, playerData)
    end

    Stats.SendData(string.format("match/%s/%s", GameRules:GetMatchID(), roundNumber), data)
end

function Stats.SubmitMatchWinner(winner, callback)
    Stats.SendData(string.format("winner/%s", GameRules:GetMatchID(), roundNumber), { winnerTeam = winner }, callback)
end

function Stats.SendData(url, data, callback)
    local req = CreateHTTPRequest("POST", Stats.host..url)
    local encoded = json.encode(data)
    print(encoded)

    req:SetHTTPRequestGetOrPostParameter('data', encoded)
    req:Send(function(res)
        if res.StatusCode ~= 200 then
            print("Server connection failure")
            return
        end

        if callback then
            local obj, pos, err = json.decode(res.Body)
            callback(obj)
        end
    end)
end
