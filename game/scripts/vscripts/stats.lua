Stats = Stats or {}

Stats.host = "http://127.0.0.1:5141/"

function Stats.SubmitMatchInfo(players, mode, version)
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

    Stats.SendData(string.format("match/%s", GameRules:GetMatchID()), data)
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

        table.insert(data.players, playerData)
    end

    Stats.SendData(string.format("match/%s/%s", GameRules:GetMatchID(), roundNumber), data)
end

function Stats.SubmitMatchWinner(winner)
    Stats.SendData(string.format("winner/%s", GameRules:GetMatchID(), roundNumber), { winner = winner })
end

function Stats.SendData(url, data)
    local req = CreateHTTPRequest("POST", Stats.host..url)
    local encoded = json.encode(data)
    print(encoded)

    req:SetHTTPRequestGetOrPostParameter('data', encoded)
    req:Send(function(res)
        if res.StatusCode ~= 200 or not res.Body then
            print("Server connection failure")
            return
        end

        --local obj, pos, err = json.decode(res.Body, 1, nil)
        --callback(err, obj)
    end)
end
