Stats = Stats or {}

Stats.host = "http://138.68.73.132:3637/"
Stats.maps = {
    ranked_1v1 = "RANKED_2",
    ranked_2v2 = "RANKED_4",
    ranked_3v3 = "RANKED_6",
    unranked = "UNRANKED"
}

Stats.roundInfo = {}
Stats.roundNumber = 0

if IsInToolsMode() then
    Stats.host = "http://127.0.0.1:5141/"

    local oldGetter = CDOTA_PlayerResource.GetSteamID

    CDOTA_PlayerResource.GetSteamID = function(self, playerId)
        local steamId = oldGetter(self, playerId)

        if tostring(steamId) == "0" then
            return playerId
        end

        return steamId
    end
end

function Stats.SubmitMatch(players, mode, version, winner, callback)
    local data = {}
    data.mode = mode
    data.version = version
    data.players = {}
    data.map = Stats.maps[GetMapName()]
    data.gameLength = math.ceil(GameRules:GetGameTime())
    data.winnerTeam = winner
    data.rounds = Stats.roundInfo

    for _, player in pairs(players) do
        local playerData = {}
        playerData.steamId64 = tostring(PlayerResource:GetSteamID(player.id))
        playerData.team = player.team

        table.insert(data.players, playerData)
    end

    local questProgress = Quests.GetProgressReport()

    setmetatable(questProgress, { __jsontype = "object" })

    data.questProgress = {
        questProgress = questProgress,
        passPlayers = FilterPassPlayers(players)
    }

    Stats.SendData(string.format("match/%s", GameRules:GetMatchID()), data, callback, 30)
end

function Stats.RequestMatchAchievements(players, callback)
    local result = {}

    for _, player in pairs(players) do
        table.insert(result, tostring(PlayerResource:GetSteamID(player.id)))
    end

    Stats.SendData("match/achievements", { players = result }, callback, 30)
end

function Stats.SubmitRoundInfo(players, roundWinner, statistics)
    local data = {}

    data.winner = roundWinner
    data.roundNumber = Stats.roundNumber
    data.players = {}

    Stats.roundNumber = Stats.roundNumber + 1

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

    table.insert(Stats.roundInfo, data)
end

function Stats.RequestTopPlayers(callback)
    Stats.RequestData("ranks/top", callback)
end

function Stats.RequestData(url, callback, rep)
    local req = CreateHTTPRequestScriptVM("GET", Stats.host..url)
    req:Send(function(res)
        if res.StatusCode ~= 200 then
            print("Server connection failure")

            if rep ~= nil and rep > 0 then
                print("Repeating in 3 seconds")

                Timers:CreateTimer(3, function() Stats.SendData(url, callback, rep - 1) end)
            end

            return
        end

        if callback then
            print("[STATS] Received", res.Body)
            local obj, pos, err = json.decode(res.Body)
            callback(obj)
        end
    end)
end

function Stats.SendData(url, data, callback, rep)
    local req = CreateHTTPRequestScriptVM("POST", Stats.host..url)
    local encoded = json.encode(data)
    print("[STATS] URL", url, "payload:", encoded)

    req:SetHTTPRequestGetOrPostParameter('data', encoded)
    req:Send(function(res)
        if res.StatusCode ~= 200 then
            print("[STATS] Server connection failure, code", res.StatusCode)

            if rep ~= nil and rep > 0 then
                print("[STATS] Repeating in 3 seconds")

                Timers:CreateTimer(3, function() Stats.SendData(url, data, callback, rep - 1) end)
            end

            return
        end

        if callback then
            print("[STATS] Received", res.Body)
            local obj, pos, err = json.decode(res.Body)
            callback(obj)
        end
    end)
end

--Stats.RequestData("quests/mock/76561198046920629", function(...) GameRules.GameMode:OnQuestResultsReceived(...) end)