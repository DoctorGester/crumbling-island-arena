HeroSelection = HeroSelection or class({})

function HeroSelection:constructor(players, availableHeroes, teamColors)
    self.SelectionTimer = 0
    self.SelectionTimerTime = 20
    self.PreGameTimer = 0
    self.PreGameTimerTime = 3
    self.Players = players
    self.TeamColors = teamColors
    self.AvailableHeroes = availableHeroes
    self.HardHeroesLocked = true
end

function HeroSelection:UpdateSelectedHeroes()
    local selected = {}

    for _, player in pairs(self.Players) do
        if player:IsConnected() then
            selected[player.id] = player.selectedHero or "null"
        end
    end

    CustomNetTables:SetTableValue("main", "selectedHeroes", selected)
end

function HeroSelection:CanBeSelected(hero)
    local entry = self.AvailableHeroes[hero]

    if self.HardHeroesLocked and entry and entry.difficulty == "hard" then
        return false
    end

    for _, player in pairs(self.Players) do
        if player.selectedHero == hero then
            return false
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

    if not self:CanBeSelected(hero) then
        return
    end

    table.player = args.PlayerID
    table.hero = hero

    CustomGameEventManager:Send_ServerToAllClients("selection_hero_hover_client", table)
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

    if not self:CanBeSelected(hero) then
        return
    end

    player.selectionLocked = true
    player.selectedHero = hero

    self:UpdateSelectionState()
    self:UpdateSelectedHeroes()

    Statistics.AddPlayedHero(player, hero)
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
        if self:CanBeSelected(i) then
            table[index] = i
            index = index + 1
        end
    end

    player.selectionLocked = true
    player.selectedHero = table[RandomInt(0, index - 1)]
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

    EmitAnnouncerSound("announcer_announcer_choose_hero")

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
    self.SelectionTimer = math.max(self.SelectionTimer - 1, -1)
    self:SendTimeToPlayers()

    if self.SelectionTimer == 0 then
        self:AssignRandomHeroes()
    end

    if self.SelectionTimer == -1 then
        if self.PreGameTimer == self.PreGameTimerTime then
            EmitAnnouncerSound("announcer_announcer_battle_prepare_01")
            --EmitAnnouncerSound("announcer_ann_custom_round_begin_01")
        end

        self.PreGameTimer = self.PreGameTimer - 1

        if self.PreGameTimer == 0 then
            self:End()
        end
    end
end