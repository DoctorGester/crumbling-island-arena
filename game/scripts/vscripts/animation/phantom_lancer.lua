model:CreateSequence(
	{
		name = "attack_q",
		sequences = {
			{ "attack_alt2" }
		},
		activities = {
			{ name = "ACT_DOTA_ATTACK2", weight = 1 }
		}
	}
)

model:CreateSequence(
	{
		name = "cast_w",
		sequences = {
			{ "loadout_ancestorspride" }
		},
		activities = {
			{ name = "ACT_DOTA_OVERRIDE_ABILITY_2", weight = 1 }
		}
	}
)