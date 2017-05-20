var playerToggles = {};
var playerRanks = {};

var stagePanels = {
    stage_mode: "ModeVoteDialog",
    stage_team: "TeamSelectDialog",
    stage_bans: "BansDialog"
};

var lastStage = null;

function OnTimerTick(args){
    var timers = $.GetContextPanel().FindChildrenWithClassTraverse("VotingTimer");

    for (var timer of timers) {
        if (args["time"] != -1) {
            timer.text = args["time"].toString();
            Game.EmitSound("UI.TimerTick");
        } else {
            timer.text = $.Localize("#GameInfoTimesUp");
        }
    }
}

function ModeVotesChanged(players) {
    players = players.inputs;

    var panel = $("#ModeVoteDialog");

    var votes = panel.FindChildrenWithClassTraverse("PlayerVotes")[0];

    for (var index in players) {
        var player = players[index];
        var id = player.id;
        var playerVotes = votes.playerVotes;

        if (!playerVotes) {
            playerVotes = {};
            votes.playerVotes = playerVotes;
        }

        if (!playerVotes[id]) {
            playerVotes[id] = $.CreatePanel("Panel", votes, "");
            playerVotes[id].AddClass("PlayerVote");

            var avatar = $.CreatePanel("DOTAAvatarImage", playerVotes[id], "");
            avatar.style.width = "100%";
            avatar.style.height = "100%";

            TryFetchSteamId(id, avatar);

            playerVotes[id].front = $.CreatePanel("Panel", playerVotes[id], "");
            playerVotes[id].front.AddClass("PlayerVoteFront");
        }

        if (player.input != null) {
            playerVotes[id].front.SetHasClass("PlayerVote" + player.input, true);
        }
    }
}

function GameSetupChanged(data){
    var newStage = data.stage;

    if (newStage != lastStage) {
        $.Msg(lastStage + "->" + newStage);

        if (!!lastStage) {
            $("#" + stagePanels[lastStage]).SetHasClass("ShowVotingPanel", false);
            $("#" + stagePanels[lastStage]).SetHasClass("HideVotingPanel", true);
        }
        
        if (!!newStage) {
            $("#" + stagePanels[newStage]).SetHasClass("VotingPanelHidden", false);
            $("#" + stagePanels[newStage]).SetHasClass("ShowVotingPanel", true);
        }

        lastStage = newStage;

        if (!newStage) {
            Game.EmitSound("UI.SetupEnd");
        } else {
            Game.EmitSound("UI.Whoosh");
        }
    }

    var stageMode = data.outputs.stage_mode;

    if (stageMode && stageMode.selectedMode) {
        $("#ModeSelectHeader").text = $.Localize("GameSetupHeader_" + stageMode.selectedMode);
    }
}

function GameStateChanged(data){
    var gameSetup = $.GetContextPanel();

    if (data.state == GAME_STATE_GAME_SETUP){
        gameSetup.style.visibility = "visible";
        SwitchClass(gameSetup, "AnimationGameSetupInvisible", "AnimationGameSetupVisible");
    } else {
        SwitchClass(gameSetup, "AnimationGameSetupVisible", "AnimationGameSetupInvisible");
    }
}

function AddModeSelectionEvent(button, mode) {
    button.SetPanelEvent("onactivate", function() {
        GameEvents.SendCustomGameEventToServer("stage_mode", { input: mode });
    });
}

function GameModesChanges(data) {
    var modesPanel = $("#ModeVoteDialog");
    var buttons = modesPanel.FindChildrenWithClassTraverse("VotingButtons")[0];
    buttons.RemoveAndDeleteChildren();

    for (var key in data) {
        var mode = data[key];

        var button = $.CreatePanel("Button", buttons, mode + "Button");
        button.AddClass("VotingButton");

        var label = $.CreatePanel("Label", button, "");
        label.text = $.Localize("#GameSetup" + mode);

        AddModeSelectionEvent(button, mode);
    }
}

function AddTeammateSelectionEvent(toggle) {
    toggle.SetPanelEvent("onactivate", function() {
        var selectedPlayers = [];

        for (var id in playerToggles) {
            if (playerToggles[id].checked) {
                selectedPlayers.push(id);
            }
        }

        GameEvents.SendCustomGameEventToServer("stage_team", { input: selectedPlayers });
    });
}

function TeamsChanged(data) {
    data = data.inputs;

    var buttonParent = $("#TeamSelectionButtons");

    for (var key in data) {
        var player = data[key];

        if (player.id != Game.GetLocalPlayerID()) {
            if (!playerToggles[player.id]) {
                var parent = $.CreatePanel("Panel", buttonParent, "");
                parent.AddClass("TeamSelectionPanel");

                var rank = $.CreatePanel("Panel", parent, "");
                rank.AddClass("TeamSelectionRankContainer");

                playerRanks[player.id] = rank;

                var avatarParent = $.CreatePanel("Panel", parent, "");
                avatarParent.AddClass("TeamSelectionAvatar");

                var avatar = $.CreatePanel("DOTAAvatarImage", avatarParent, "");
                avatar.style.width = "100%";
                avatar.style.height = "100%";

                TryFetchSteamId(player.id, avatar);

                var name = $.CreatePanel("Label", parent, "");
                name.AddClass("TeamSelectionName");
                name.text = Players.GetPlayerName(player.id);

                var toggle = $.CreatePanel("ToggleButton", parent, "");

                playerToggles[player.id] = toggle;

                AddTeammateSelectionEvent(toggle);
            } else {
                playerToggles[player.id].checked = false;
            }
        }
    }

    var checked = 0;

    for (var key in data) {
        var player = data[key];

        if (player.id == Game.GetLocalPlayerID()) {
            if (player.input) {
                for (var index in player.input) {
                    var id = player.input[index];

                    if (playerToggles[id]) {
                        playerToggles[id].checked = true;
                        checked++;
                    }
                }
            }
        }
    }

    var state = CustomNetTables.GetTableValue("gameSetup", "state");

    if (state && state.outputs.stage_mode) {
        for (var k in playerToggles) {
            var toggle = playerToggles[k];

            if (checked + 1 >= state.outputs.stage_mode.playersInTeam) {
                toggle.enabled = toggle.checked
            } else {
                toggle.enabled = true;
            }
        }
    }
}

function RanksChanged(ranks) {
    for (var k in playerRanks) {
        if (ranks[k]) {
            playerRanks[k].RemoveAndDeleteChildren();

            CreateRankPanelSmall(playerRanks[k], ranks[k], "PlayerRank");
        }
    }
}

function MiscInfoChanged(data) {
    var labels = $.GetContextPanel().FindChildrenWithClassTraverse("MatchModeHeader");

    if (data.rankedMode != null){
        for (var label of labels) {
            label.text = $.Localize("#Ranked");
        }

        for (var k in playerRanks) {
            if (playerRanks[k].Children().length == 0) {
                var loading = $.CreatePanel("Panel", playerRanks[k], "");
                loading.AddClass("LoadingImage");
            }
        }
    }// else {
        for (var k in playerRanks) {
            playerRanks[k].AddClass("Hidden");
        }
    //}
}

function AddBanEvent(button, ban) {
    button.onactivate = function() {
        GameEvents.SendCustomGameEventToServer("stage_bans", { input: ban });
    };
}

function ConfirmBan() {
    GameEvents.SendCustomGameEventToServer("stage_bans_confirm", {});
}

function BansUpdated(data) {
    var heroes = data.heroes;
    var bans = data.stage_bans;

    // TODO fix the bug
    if (!heroes) {
        return;
    }

    var struct = [];
    var heroNames = Object.keys(heroes);
    var bannedHeroes = {};
    var local = Game.GetLocalPlayerID();

    if (bans) {
        bans = bans.inputs;

        var info = Game.GetPlayerInfo(local);
        var localTeam = info ? info.player_team_id : -1;

        for (var index in bans) {
            var player = bans[index];
            var team = Game.GetPlayerInfo(player.id).player_team_id;

            if (player.input && (team == localTeam || localTeam == -1)) {
                for (var key in player.input.bans) {
                    if (!!player.input.bans[key]) {
                        bannedHeroes[key] = true;
                    }
                }
            }
        }
    }

    heroNames = _(heroNames).sortBy(function(hero) { return heroes[hero].order });

    for (var hero of heroNames) {
        var data = heroes[hero];

        if (data.disabled) {
            continue;
        }

        var btn = {
            tag: "DOTAHeroImage",
            heroname: hero,
            class: [ "BanButton", bannedHeroes[hero] ? "Banned" : null ],
            scaling: "stretch-to-fit-x-preserve-aspect",
            onactivate: function() {
                GameEvents.SendCustomGameEventToServer("stage_bans", { input: ban });
            },
            onChange: function() {
                Game.EmitSound("UI.HeroBanned");
            },
            children: [
                {
                    class: [ !bannedHeroes[hero] ? "Hidden" : null ],
                    hittest: false
                },
                {
                    class: [ "Second", !bannedHeroes[hero] ? "Hidden" : null ],
                    hittest: false
                }
            ]
        };

        AddBanEvent(btn, hero);

        struct.push(btn);
    }

    Structure.Create($("#BanButtons"), struct);
}

(function () {
    SubscribeToNetTableKey("main", "gameState", true, GameStateChanged);
    SubscribeToNetTableKey("gameSetup", "modes", true, GameModesChanges);
    SubscribeToNetTableKey("gameSetup", "stage_mode", true, ModeVotesChanged);
    SubscribeToNetTableKey("gameSetup", "stage_team", true, TeamsChanged);

    SubscribeToNetTableKey("gameSetup", "state", true, GameSetupChanged);
    SubscribeToNetTableKey("gameSetup", "misc", true, MiscInfoChanged);
    SubscribeToNetTableKey("ranks", "current", true, RanksChanged);

    AggregateNetTables([
        { table: "static", key: "heroes" },
        { table: "gameSetup", key: "stage_bans" }
    ], BansUpdated);

    GameEvents.Subscribe("setup_timer_tick", OnTimerTick);
    //$("#GameSetupChat").BLoadLayout("file://{resources}/layout/custom_game/simple_chat.xml", false, false);
    //$("#GameSetupChat").RegisterListener("GameSetupEnter");
})();