modifier_player_id = class({})

-- This modifier is necessary for the following reasons:
-- GetPlayerOwnerID returns -1 for a units created with nil-nil owners and without an explicit ID
-- Setting ID through SetPlayerID causes the hero to have playername displayed over his corpse after death

function modifier_player_id:IsHidden()
    return true
end