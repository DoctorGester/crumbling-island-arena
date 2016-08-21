MessageQueue = new (function() {
    this.queue = [];
    this.busy = false;

    this.CheckQueue = function() {
        $.Schedule(0.1, (function(q) {
            return function() {
                q.CheckQueue();
            }
        })(this));

        if (!this.busy && this.queue.length > 0) {
            var message = this.queue.shift();

            this.PlayMessage(message.hero, message.token, message.sound);
        }
    }

    this.QueueMessage = function(hero, token, sound) {
        this.queue.push({ hero: hero, token: token, sound: sound });
    }

    this.PlayMessage = function(hero, token, sound) {
        this.busy = true;

        var split = $.Localize(token).toUpperCase().split(" ");

        $("#KillMessageTop").text = split[0];
        $("#KillMessageBottom").text = split[1];
        $("#KillMessageIconTop").heroname = hero;
        $("#KillMessageIconBottom").heroname = hero;

        var anims = {
            "KillMessageTop" : "AnimKillMessageTop",
            "KillMessageBottom" : "AnimKillMessageBottom",
            "KillMessageIconContainerTop" : "AnimKillIconTop",
            "KillMessageIconContainerBottom" : "AnimKillIconBottom",
            "KillMessageCutterTop": "AnimKillMessageCutterTop",
            "KillMessageCutterBottom": "AnimKillMessageCutterBottom",
        };

        for (var element in anims) {
            $("#" + element).SetHasClass(anims[element], false);
            $("#" + element).SetHasClass(anims[element], true);
        }

        Game.EmitSound("UI.HeroKilled");
        Game.EmitSound("UI.HeroKilledEnd");

        if (sound) {
            Game.EmitSound(sound);
        }

        $.Schedule(1.9, (function(q) {
            return function() {
                q.busy = false;

                for (var element in anims) {
                    $("#" + element).SetHasClass(anims[element], false);
                }
            }
        })(this));
    }

    this.CheckQueue();
})();