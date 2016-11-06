EGG_MODIFIER = "modifier_phoenix_egg"

Phoenix = class({}, {}, Mixin)

function Phoenix:Init(hero)
    hero:AddNewModifier(hero, hero:FindAbility("phoenix_w"), "modifier_charges",
        {
            max_count = 2,
            replenish_time = 6
        }
    )

    hero:AddNewModifier(hero, nil, "modifier_phoenix_egg_tooltip", {})
end

function Phoenix:Dispose() end