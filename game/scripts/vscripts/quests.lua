Quests = Quests or {}

Quests.MAPPED_TYPES = {
    damageDealt = "DEAL_DAMAGE",
    mvps = "EARN_MVP",
    firstBloods = "EARN_FIRST_BLOOD",
    kills = "MAKE_KILLS",
    healingReceived = "RESTORE_HEALTH",
    spellsCast = "CAST_SPELLS",
    gamesPlayed = "PLAY_GAMES"
}

if IsInToolsMode() then
    CDOTA_PlayerResource.HasCustomGameTicketForPlayerID = function(self, playerId)
        return true
    end
end

function Quests.Init(players)
    local data = {
        players = FilterPassPlayers(players)
    }

    Stats.SendData("quests/update", data, function(...) Quests.UpdateQuests(...) end, 30)
end

function Quests.UpdateQuests(data)
    Quests.quests = GameRules.GameMode:ParseSteamId64Table(data)
    Quests.NetworkQuests()

    if Quests.quests then
        for _, quests in pairs(Quests.quests) do
            for _, quest in pairs(quests) do
                quest.isNew = false
            end
        end
    end
end

function Quests.NetworkQuests()
    CustomNetTables:SetTableValue("pass", "quests", Quests.quests)
end

function Quests.GetProgressReport()
    local result = {}

    if Quests.quests then
        for _, quests in pairs(Quests.quests) do
            for _, quest in pairs(quests) do
                result[quest.id] = quest.progress
                hasKeys = true
            end
        end
    end

    return result
end

function Quests.FindQuestForPlayerWithType(playerId, questType)
    for _, quest in pairs(Quests.quests[playerId] or {}) do
        if quest.type == questType then
            return quest
        end
    end

    return nil
end

function Quests.IncreaseQuestProgress(quest)
    if quest then
        quest.progress = math.min(quest.progress + 1, quest.goal)
        Quests.NetworkQuests()
    end
end

function Quests.IncreaseProgress(player, questType, hero)
    if Quests.quests then
        local mappedType = Quests.MAPPED_TYPES[questType]
            
        if mappedType then
            local quest = Quests.FindQuestForPlayerWithType(player.id, mappedType)
            Quests.IncreaseQuestProgress(quest)
        else
            if questType == "hero" then
                local quest = Quests.FindQuestForPlayerWithType(player.id, "PLAY_ROUNDS_AS")

                hero = hero:upper():sub(("npc_dota_hero_"):len() + 1)

                if quest and quest.hero == hero then
                    Quests.IncreaseQuestProgress(quest)
                end

                quest = Quests.FindQuestForPlayerWithType(player.id, "PLAY_ROUNDS_AS_OR")

                if quest and (quest.hero == hero or quest.secondaryHero == hero) then
                    Quests.IncreaseQuestProgress(quest)
                end
            end
        end
    end
end