function Vote(event, key, value) {
    var ev = {};
    ev[key] = value;
    GameEvents.SendCustomGameEventToServer(event, ev);
}

function OnTimerTick(args){
    var timers = $.GetContextPanel().FindChildrenWithClassTraverse("VotingTimer");
    Game.EmitSound("UI.TimerTick");

    for (var timer of timers) {
        if (args["time"] != -1) {
            timer.text = args["time"].toString();
        } else {
            timer.text = $.Localize("#GameInfoTimesUp");
        }
    }
}

function TryFetchSteamId(avatar) {
    var info = Game.GetPlayerInfo(Number(id));

    if (!info) {
        $.Schedule(0.1, function() {
            TryFetchSteamId(avatar);
        });
    } else {
        avatar.steamid = info.player_steamid;
    }
}

function UpdatePlayerVotes(panel, players, key, map) {
    var votes = panel.FindChildrenWithClassTraverse("PlayerVotes")[0];

    for (id in players) {
        var player = players[id];
        var playerVotes = votes.playerVotes;

        if (!playerVotes) {
            playerVotes = {};
            votes.playerVotes = playerVotes;
        }

        if (!playerVotes[id]) {
            playerVotes[id] = $.CreatePanel("DOTAAvatarImage", votes, "");
            playerVotes[id].AddClass("PlayerVote");

            TryFetchSteamId(playerVotes[id]);

            playerVotes[id].front = $.CreatePanel("Panel", playerVotes[id], "");
            playerVotes[id].front.AddClass("PlayerVoteFront");
        }

        if (player[key] != null) {
            playerVotes[id].front.SetHasClass(map[player[key].toString()], true);
        }
    }
}

function GameSetupChanged(data){
    if (!data) {
        return;
    }

    UpdatePlayerVotes($("#ModeVoteDialog"), data.players, "selectedMode", { "ffa": "PlayerVoteFFA", "2v2": "PlayerVote2v2" });
    UpdatePlayerVotes($("#TeamSelectDialog"), data.players, "selectedTeam", { "0": "PlayerVoteTeam1", "1": "PlayerVoteTeam2" });

    if (data.stage == 1) {
        $("#ModeVoteDialog").SetHasClass("HideVotingPanel", true);
        $("#TeamSelectDialog").SetHasClass("VotingPanelHidden", false);
        $("#TeamSelectDialog").SetHasClass("ShowVotingPanel", true);
    }

    if (data.selectedMode) {
        Game.EmitSound("UI.Whoosh");
        $("#ModeSelectHeader").text = $.Localize("GameSetupHeader_" + data.selectedMode);
    }
}

function GameStateChanged(data){
    var gameSetup = $.GetContextPanel();

    if (data.state == GAME_STATE_GAME_SETUP){
        gameSetup.style.visibility = "visible";
        SwitchClass(gameSetup, "AnimationGameSetupInvisible", "AnimationGameSetupVisible");
    } else {
        if (gameSetup.BHasClass("AnimationGameSetupVisible")) {
            Game.EmitSound("UI.SetupEnd");
        }
        
        SwitchClass(gameSetup, "AnimationGameSetupVisible", "AnimationGameSetupInvisible");
    }
}

(function () {
    SubscribeToNetTableKey("main", "gameState", true, GameStateChanged);
    SubscribeToNetTableKey("main", "gameSetup", true, GameSetupChanged);
    GameEvents.Subscribe("setup_timer_tick", OnTimerTick);

    //$("#GameSetupChat").BLoadLayout("file://{resources}/layout/custom_game/simple_chat.xml", false, false);
    //$("#GameSetupChat").RegisterListener("GameSetupEnter");
})();