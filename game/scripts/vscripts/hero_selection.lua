HeroSelection = HeroSelection or class({})

function HeroSelection:constructor(players, availableHeroes, teamColors, chat, allowSameHeroPicks, hiddenPick)
    self.SelectionTimer = 0
    self.SelectionTimerTime = 20
    self.PreGameTimer = 0
    self.PreGameTimerTime = 3
    self.Players = players
    self.TeamColors = teamColors
    self.AvailableHeroes = availableHeroes
    self.PreviousRandomed = {}
    self.Chat = chat
    self.AllowSameHeroPicks = allowSameHeroPicks
    self.HiddenPick = hiddenPick
end

function HeroSelection:UpdateSelectedHeroes()
    local selected = {}

    for _, player in pairs(self.Players) do
        if player:IsConnected() then
            selected[player.id] = player.selectedHero or "null"
        end
    end

    CustomNetTables:SetTableValue("main", "selectedHeroes", {
        selected = selected,
        allowSame = self.AllowSameHeroPicks,
        locked = self.SelectionTimer <= 0,
        hiddenPick = self.HiddenPick
    })
end

function HeroSelection:CanBeSelectedBy(hero, who)
    local entry = self.AvailableHeroes[hero]

    if entry and (entry.disabled or entry.banned) then
        return false
    end

    for _, player in pairs(self.Players) do
        if player.selectedHero == hero then
            if self.AllowSameHeroPicks then
                if who.team == player.team then
                    return false
                end
            else
                return false
            end
        end
    end

    return true
end

function HeroSelection:OnRandom(args)
    local player = self.Players[args.PlayerID]

    if player:IsConnected() and not player.selectionLocked then
        self:AssignRandomHero(player)
        self:UpdateSelectionState()
        self:UpdateSelectedHeroes()
    end
end

function HeroSelection:OnHover(args)
    local table = {}
    local player = self.Players[args.PlayerID]
    local hero = args.hero

    if not player:IsConnected() then
        return
    end

    if self.AvailableHeroes[hero] == nil and hero ~= "null" then
        return
    end

    if player.selectionLocked then
        return
    end

    if not self:CanBeSelectedBy(hero, player) then
        return
    end

    table.player = args.PlayerID
    table.hero = hero

    if self.AllowSameHeroPicks then
        CustomGameEventManager:Send_ServerToTeam(player.team, "selection_hero_hover_client", table)
    else
        CustomGameEventManager:Send_ServerToAllClients("selection_hero_hover_client", table)
    end
end

function HeroSelection:OnClick(args)
    local table = {}
    local player = self.Players[args.PlayerID]
    local hero = args.hero

    if not player:IsConnected() then
        return
    end

    if self.AvailableHeroes[hero] == nil then
        return
    end

    if player.selectionLocked then
        return
    end

    if not self:CanBeSelectedBy(hero, player) then
        return
    end

    player.selectionLocked = true
    player.selectedHero = hero

    self:UpdateSelectionState()
    self:UpdateSelectedHeroes()
end

function HeroSelection:UpdateSelectionState()
    local allLocked = true
    for _, playerClass in pairs(self.Players) do
        if playerClass:IsConnected() and not playerClass.selectionLocked then
            allLocked = false
        end
    end

    if allLocked and self.SelectionTimer > 3 then
        self.SelectionTimer = 3
        self:SendTimeToPlayers()
    end
end

function HeroSelection:AssignRandomHero(player)
    local table = {}
    local index = 0

    for i, _ in pairs(self.AvailableHeroes) do
        if self:CanBeSelectedBy(i, player) and self.PreviousRandomed[player.id] ~= i then
            table[index] = i
            index = index + 1
        end
    end

    player.selectionLocked = true
    player.selectedHero = table[RandomInt(0, index - 1)]

    self.PreviousRandomed[player.id] = player.selectedHero
    self.Chat:PlayerRandomed(player.id, player.selectedHero, self.HiddenPick and self.SelectionTimer > 0)
end

function HeroSelection:AssignRandomHeroes()
    for i, player in pairs(self.Players) do
        if player:IsConnected() then
            if not player.selectionLocked then
                self:AssignRandomHero(player)
            end
        end
    end

    self:UpdateSelectedHeroes()
end

function HeroSelection:SendTimeToPlayers()
    CustomGameEventManager:Send_ServerToAllClients("timer_tick", { time = self.SelectionTimer })
end

function HeroSelection:Start(callback)
    print("Starting hero selection")

    self.Callback = callback
    self.SelectionTimer = self.SelectionTimerTime
    self.PreGameTimer = self.PreGameTimerTime
    self:SendTimeToPlayers()

    for _, player in pairs(self.Players) do
        player.selectedHero = nil
        player.selectionLocked = false
    end

    self:UpdateSelectedHeroes()

    EmitAnnouncerSound("Announcer.SelectionChoose")

    self.HoverListener = CustomGameEventManager:RegisterListener("selection_hero_hover", function(id, ...) Dynamic_Wrap(self, "OnHover")(self, ...) end)
    self.ClickListener = CustomGameEventManager:RegisterListener("selection_hero_click", function(id, ...) Dynamic_Wrap(self, "OnClick")(self, ...) end)
    self.RandomListener = CustomGameEventManager:RegisterListener("selection_random", function(id, ...) Dynamic_Wrap(self, "OnRandom")(self, ...) end)
end

function HeroSelection:End()
    CustomGameEventManager:UnregisterListener(self.HoverListener)
    CustomGameEventManager:UnregisterListener(self.ClickListener)
    CustomGameEventManager:UnregisterListener(self.RandomListener)
    
    self:Callback()
end

function HeroSelection:Update()
    if GameRules.GameMode:FindTheOnlyConnectedTeam() then
        self.SelectionTimer = 10
        self.PreGameTimer = self.PreGameTimerTime
        self:SendTimeToPlayers()
        return
    end

    self.SelectionTimer = math.max(self.SelectionTimer - 1, -1)
    self:SendTimeToPlayers()

    if self.SelectionTimer == 0 then
        self:AssignRandomHeroes()
        SystemMessage("#SystemRoundStart", { round = GameRules.GameMode.roundNumber })
    end

    if self.SelectionTimer == 5 then
        EmitAnnouncerSound("Announcer.SelectionSoon")
    end

    if self.SelectionTimer == -1 then
        if self.PreGameTimer == self.PreGameTimerTime then
            EmitAnnouncerSound("Announcer.SelectionPrepare")
        end

        self.PreGameTimer = self.PreGameTimer - 1

        if self.PreGameTimer == 0 then
            self:End()
        end
    end
end