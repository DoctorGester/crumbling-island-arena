Debug = class({})

if not mode then
	mode = nil
end

function OnTakeDamage(eventSourceIndex, args)
	mode.Round:DealDamage(mode.Players[args.PlayerID].hero, mode.Players[args.PlayerID].hero, false)
end

function OnHealHealth(eventSourceIndex, args)
	mode.Round:Heal(mode.Players[args.PlayerID].hero)
end

function OnShowSelection(eventSourceIndex, args)
	mode.Round:CheckEndConditions()
end

function Debug:CheckAndEnableDebug(gameMode)
	local cheatsEnabled = Convars:GetInt("sv_cheats") == 1

	CustomNetTables:SetTableValue("main", "debug", { enabled = cheatsEnabled })

	if not cheatsEnabled then
		return
	end

	mode = gameMode

	CustomGameEventManager:RegisterListener("debug_take_damage", OnTakeDamage)
	CustomGameEventManager:RegisterListener("debug_heal_health", OnHealHealth)
	CustomGameEventManager:RegisterListener("debug_show_selection", OnShowSelection)

	GameRules.GameMode.Round.StageTwoTimerTime = 1500
	GameRules.GameMode.Round.StageThreeTimerTime = 4000
	GameRules.GameMode.Round.UltsTimerTime = 150
	GameRules.GameMode.Round.SuddenDeathTimerTime = 60000

	GameRules.GameMode.HeroSelection.SelectionTimerTime = 2000
	GameRules.GameMode.HeroSelection.PreGameTime = 0
end