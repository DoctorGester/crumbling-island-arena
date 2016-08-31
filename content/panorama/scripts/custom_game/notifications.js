var NotificationQueue = new (function() {
    this.queue = [];
    this.busy = false;

    this.AddNotification = function(snippetName, callback, data) {
        this.queue.push({ snippet: snippetName, callback: callback, data: data });

        if (!this.busy) {
            this.ShowNextNotification();
        }
    }

    this.ShowNextNotification = function() {
        var notification = this.queue.shift();

        this.busy = true;

        $("#GameOverBlur").SetHasClass("Blurred", true);
        $("#NotificationArea").SetHasClass("Hidden", false);
        $("#NotificationArea").BLoadLayoutSnippet(notification.snippet);
        notification.callback(notification.data);

        $.Schedule(2, function() {
            $("#NotificationArea").SetPanelEvent("onactivate", function() {
                NotificationQueue.HideNotification();
            });
        })
    }

    this.HideNotification = function() {
        $("#GameOverBlur").SetHasClass("Blurred", false);
        $("#NotificationArea").SetHasClass("Hidden", true);
        $("#NotificationArea").ClearPanelEvent("onactivate");
        $("#NotificationArea").RemoveAndDeleteChildren();

        this.busy = this.queue.length > 0;

        if (this.busy) {
            this.ShowNextNotification();
        } else {
            Game.EmitSound("UI.NotificationClose");
        }
    }
});

function RankNotification(ranks) {
    var previous = ranks.previous;
    var updated = ranks.updated;

    var lostStreak = (updated.streak && previous.streak && updated.streak.current < previous.streak.current);

    var rankPanel = $("#Rank");
    var newRankPanel = $("#RankNew");

    var elements = $("#RankElements");

    elements.SetHasClass("Hidden", true);

    $.Schedule(0.4, function() {
        Game.EmitSound("UI.RankAppear");
        elements.SetHasClass("Hidden", false);
        elements.RemoveClass("RankOpenAnimationClass");
        elements.AddClass("RankOpenAnimationClass");
    });

    $("#GameOverBlur").AddClass("Blurred");
    rankPanel.SetImage("file://{images}/profile_badges/level_" + (100 - previous.rank) + ".png");

    rankPanel.SetHasClass("Hidden", false);
    
    newRankPanel.SetImage("file://{images}/profile_badges/level_" + (100 - updated.rank) + ".png");
    newRankPanel.SetHasClass("Hidden", true);

    UpdateLabelFromRank($("#RankLabel"), previous);
    UpdateLabelFromRank($("#RankLabelNew"), updated);

    $("#EliteRankText").text = "";

    $.Schedule(1.8, function() {
        rankPanel.RemoveClass("RankEndAnimationClass");
        rankPanel.AddClass("RankEndAnimationClass");
    });

    $.Schedule(2, function() {
        if (updated.rank > previous.rank || lostStreak) {
            Game.EmitSound("UI.RankDecrease");
        } else if (updated.rank > 20) {
            Game.EmitSound("UI.RankLow");
        } else if (updated.rank > 10) {
            Game.EmitSound("UI.RankMedium");
        } else {
            Game.EmitSound("UI.RankHigh");
        }
        
        newRankPanel.SetHasClass("Hidden", false);
        rankPanel.SetHasClass("Hidden", true);
        newRankPanel.RemoveClass("RankAnimationClass");
        newRankPanel.AddClass("RankAnimationClass");

        if (updated.rank <= previous.rank && !lostStreak){
            $("#RankEffect").SetHasClass("Hidden", false);
        }

        if (updated.rank == 1 && updated.streak) {
            var label = $("#EliteRankText");

            label.SetDialogVariable("max", updated.streak.max);
            label.text = $.Localize("RankStreak", label);
        }
    });
}

function RewardNotification(data) {
    var season = data.season;
    var area = $("#RewardArea");

    area.BCreateChildren("<DOTAScenePanel id='RewardModel' map='maps/rewards/" + season + ".vmap' camera='default' light='light'/>");
    area.MoveChildBefore($("#RewardModel"), $("#RewardTip"));
    area.SetHasClass("RewardHidden", true);

    Game.EmitSound("UI.PreRewardReceived");

    $.Schedule(2.0, function() {
        Game.EmitSound("UI.RewardReceived");

        area.SetHasClass("RewardHidden", false);
        area.RemoveClass("RankOpenAnimationClass");
        area.AddClass("RankOpenAnimationClass");
    });
}
