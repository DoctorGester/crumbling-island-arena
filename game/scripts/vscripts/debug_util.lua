function OnTakeDamage(eventSourceIndex, args)
	GameRules.GameMode.Round:DealDamage(nil, GameMode.Players[args.PlayerID], true)
end

function OnHealHealth(eventSourceIndex, args)
	GameRules.GameMode.Round:Heal(GameMode.Players[args.PlayerID])
end

function OnShowSelection(eventSourceIndex, args)
	OnRoundEnd()
end

function CheckAndEnableDebug()
	local cheatsEnabled = Convars:GetInt("sv_cheats") == 1

	CustomNetTables:SetTableValue("main", "debug", { enabled = cheatsEnabled })

	if not cheatsEnabled then
		return
	end

	CustomGameEventManager:RegisterListener("debug_take_damage", OnTakeDamage)
	CustomGameEventManager:RegisterListener("debug_heal_health", OnHealHealth)
	CustomGameEventManager:RegisterListener("debug_show_selection", OnShowSelection)

	--GameRules.GameMode.Round.StageTwoTimerTime = 2500
	GameRules.GameMode.Round.StageThreeTimerTime = 4000
	GameRules.GameMode.Round.UltsTimerTime = 15
	GameRules.GameMode.Round.SuddenDeathTimerTime = 60000
end