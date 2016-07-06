function HallOfFameChanged(data) {
    if (!data) {
        return;
    }

    var parent = $("#HallOfFamePlayers");

    for (var mode in data) {
        var players = data[mode];

        if (mode == "FFA_FOUR") {
            continue;
        }

        if (players.length == 0) {
            continue;
        }

        var player = players[0];
        var playerPanel = $.CreatePanel("Panel", parent, "");
        playerPanel.AddClass("HallOfFamePlayer");

        var modeName = $.CreatePanel("Label", playerPanel, "");
        modeName.text = $.Localize("RankMode_" + mode);
        modeName.AddClass("HallOfFameMode");

        var avatarContainer = $.CreatePanel("Panel", playerPanel, "");
        avatarContainer.AddClass("HallOfFameAvatarContainer");

        var avatar = $.CreatePanel("DOTAAvatarImage", avatarContainer, "");
        avatar.steamid = player.steamId64.toString();
        avatar.AddClass("HallOfFameAvatar");

        CreateRankPanelSmall(playerPanel, player, "HallOfFameRank");

        var name = $.CreatePanel("DOTAUserName", playerPanel, "");
        name.steamid = player.steamId64.toString();
        name.AddClass("HallOfFameName");
    }
}

$.AsyncWebRequest("http://178.63.238.188:3637/ranks/top", { type: "GET", 
    success: function( data ) {
        var info = JSON.parse(data);
        HallOfFameChanged(info);
    }
});