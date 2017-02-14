model:CreateSequence(
	{
		name = "custom_run",
		sequences = {
			{ "runN" }
		},
		activities = {
			{ name = "ACT_DOTA_CHANNEL_ABILITY_3", weight = 1 }
		}
	}
)

model:CreateSequence(
	{
		name = "attack_q",
		sequences = {
			{ "attack02_anim" }
		},
		activities = {
			{ name = "ACT_DOTA_ATTACK2", weight = 1 }
		}
	}
)

model:CreateSequence(
	{
		name = "attack_w",
		sequences = {
			{ "shield_warcry_attack02_anim" }
		},
		activities = {
			{ name = "ACT_DOTA_OVERRIDE_ABILITY_2", weight = 1 }
		}
	}
)