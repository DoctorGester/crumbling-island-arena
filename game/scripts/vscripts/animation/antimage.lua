model:CreateSequence(
	{
		name = "attack_a",
		sequences = {
			{ "attack" }
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
            { "slasher_attack_alt01" }
        },
        activities = {
            { name = "ACT_DOTA_CAST_ABILITY_1", weight = 1 }
        }
    }
)