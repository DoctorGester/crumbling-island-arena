model:CreateSequence(
	{
		name = "attack_w",
		snap = true,
		sequences = {
			{ "pudge_dismember_mid" }
		},
		activities = {
			{ name = "ACT_DOTA_ATTACK2", weight = 1 }
		}
	}
)

model:CreateSequence(
	{
		name = "attack_a",
		snap = true,
		sequences = {
			{ "pudge_attack1_anim" }
		},
		activities = {
			{ name = "ACT_DOTA_CAST_ABILITY_3", weight = 1 }
		}
	}
)