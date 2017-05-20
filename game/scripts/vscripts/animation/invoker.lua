model:CreateSequence(
	{
		name = "cast_q",
		sequences = {
			{ "divine_sorrow_sunstrike" }
		},
		activities = {
			{ name = "ACT_DOTA_CAST_ABILITY_1", weight = 1 }
		}
	}
)

model:CreateSequence(
	{
		name = "cast_e",
		sequences = {
			{ "ti6_deafening_blast" }
		},
		activities = {
			{ name = "ACT_DOTA_CAST_ABILITY_3", weight = 1 }
		}
	}
)