model:CreateSequence(
	{
		name = "attack_r",
		sequences = {
			{ "attack_crit" }
		},
		activities = {
			{ name = "ACT_DOTA_ATTACK2", weight = 1 }
		}
	}
)


model:CreateSequence(
	{
		name = "cast_q",
		sequences = {
			{ "idle_alt" }
		},
		activities = {
			{ name = "ACT_DOTA_CAST_ABILITY_3", weight = 1 }
		}
	}
)