GRACE_TIME = 1
ULTS_TIME = 40

Round = Round or class({})

function Round:constructor(players, teams, availableHeroes, callback)
    self.winner = nil
    self.ended = false
    self.entityDied = false
    self.callback = callback

    self.players = players
    self.teams = teams
    self.availableHeroes = availableHeroes

    self.spells = Spells()
    self.statistics = Statistics(players)
end

function Round:CheckEndConditions()
    if self.ended then
        return
    end

    local teams = {}
    
    for _, player in pairs(self.players) do
        if player:IsConnected() and (player.hero and not player.hero.unit:IsNull() and player.hero:Alive()) then
            teams[player.team] = true
        end
    end

    local amountAlive = 0
    local lastAlive = nil

    for team, _ in pairs(teams) do
        amountAlive = amountAlive + 1
        lastAlive = team
    end

    if amountAlive <= 1 then
        self.winner = lastAlive
        self:EndRound()
    end
end

function Round:EndRound()
    for _, player in pairs(self.players) do
        if player.hero then
            self.statistics:AddPlayedHero(player, player.selectedHero)

            player.hero.protected = true
        end
    end

    self.ended = true

    EmitAnnouncerSound("announcer_ann_custom_round_complete")

    Timers:CreateTimer(GRACE_TIME, function()
        self:callback()
    end)
end

function Round:Update()
    local status, err = pcall(
        function(self)
            self.spells:Update()
        end
    , self)

    if not status then
        print(err)
    end

    if self.entityDied then
        self.entityDied = false
        self:CheckEndConditions()
    end
end

function Round:LoadHeroClass(name)
    local classValue = self.availableHeroes[name].class

    if classValue then
        print("Loading class "..classValue)

        local path, className = classValue:match("([^:]+):([^:]+)")
        require(path)
        return assert(loadstring("return "..className.."()"))()
    else
        print("Falling back to default Hero class")

        return Hero()
    end
end

function Round:GetTeamInverted(team)
    local inverted = {}

    for key, value in pairs(self.teams) do
        if value == team then
            return key
        end
    end

    return -1
end

function Round:CreateHeroes(spawnPoints)
    print("Creating heroes")
    Shuffle(spawnPoints)

    for i, player in pairs(self.players) do
        if player:IsConnected() and player.selectionLocked and player.selectedHero ~= nil then
            local hero = self:LoadHeroClass(player.selectedHero)
            local unit = CreateUnitByName(player.selectedHero, spawnPoints[self:GetTeamInverted(player.team) + 1] + RandomVector(150), true, nil, nil, player.team)
            hero:SetUnit(unit)

            hero:Setup()
            hero:SetOwner(player)

            local count = unit:GetAbilityCount() - 1
            for i = 0, count do
                local ability = unit:GetAbilityByIndex(i)

                if ability ~= nil and string.ends(ability:GetName(), "_r") then
                    ability:StartCooldown(self.availableHeroes[player.selectedHero].initialCD or ULTS_TIME)
                end
            end

            hero:Activate()

            player.hero = hero
        else
            player.hero = nil
        end
    end
end

function Round:Destroy()
    for _, player in pairs(self.players) do
        if player.hero then
            self.spells:InterruptDashes(player.hero)
            player.hero:Hide()
        end
    end

    for _, entity in pairs(self.spells.entities) do
        if instanceof(entity, Hero) then
            entity.removeOnDeath = true
        end
        
        entity:Destroy()
    end

    self:Update()
end