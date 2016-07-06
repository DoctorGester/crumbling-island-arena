var hallOfFamePlayers = {
    "FFA_FOUR": 0,
    "DUEL": 1,
    "TWO_TEAMS": 3
};

function HallOfFameChanged(data) {
    if (!data) {
        return;
    }

    var parent = $("#HallOfFamePlayers");

    for (var mode in data) {
        var players = data[mode];

        if (hallOfFamePlayers[mode] == 0) {
            continue;
        }

        var modePanel = $.CreatePanel("Panel", parent, "");
        modePanel.AddClass("HallOfFameMode");

        var modeName = $.CreatePanel("Label", modePanel, "");
        modeName.text = $.Localize("RankMode_" + mode);
        modeName.AddClass("HallOfFameModeName");

        var modePlayersPanel = $.CreatePanel("Panel", modePanel, "");
        modePlayersPanel.AddClass("HallOfFameModePlayers");

        for (var i = 0; i < hallOfFamePlayers[mode] && i < players.length; i++) {
            var player = players[i];

            var playerPanel = $.CreatePanel("Panel", modePlayersPanel, "");
            playerPanel.AddClass("HallOfFamePlayer");

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
}

$.AsyncWebRequest("http://178.63.238.188:3637/ranks/top", { type: "GET", 
    success: function( data ) {
        var info = JSON.parse(data);
        HallOfFameChanged(info);
    }
});

var hittestBlocker = $.GetContextPanel().GetParent().FindChild("LoadingScreenTournamentContainer");

if (hittestBlocker) {
    hittestBlocker.hittest = false;
}