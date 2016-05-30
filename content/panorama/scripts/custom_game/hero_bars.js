var dummy = "npc_dota_hero_wisp";
var heroBars = {};

function GetUnitOwner(unit) {
    var team = Entities.GetTeamNumber(unit);

    for (var i = 0; i < Players.GetMaxPlayers(); i++) {
        if (Players.IsValidPlayerID(i) && Entities.IsControllableByPlayer(unit, i)) {
            return i;
        }
    }
    
    return null;
}

function UpdateHeroBars(){
    $.Schedule(1 / 120, UpdateHeroBars);

    var mainPanel = $("#MainPanel");
    var all = Entities.GetAllHeroEntities();
    var onScreen = _
        .chain(all)
        .reject(function(entity) {
            return Entities.IsUnselectable(entity);
        })
        .filter(function(entity) {
            return Entities.IsAlive(entity);
        })
        .map(function(entity) {
            var abs = Entities.GetAbsOrigin(entity);
            var x = Game.WorldToScreenX(abs[0], abs[1], abs[2] + 300);
            var y = Game.WorldToScreenY(abs[0], abs[1], abs[2] + 300);

            return { id: entity, x: x, y: y };
        })
        .reject(function(mapped) {
            return mapped.x == -1 || mapped.y == -1;
        })
        .filter(function(mapped) {
            return GameUI.GetScreenWorldPosition(mapped.x, mapped.y) != null;
        })
        .each(function(entity) {
            if (_.has(heroBars, entity.id)) {
                var panel = heroBars[entity.id]

                if (panel.actuallayoutwidth != Infinity) {
                    entity.x -= panel.actuallayoutwidth / 2;
                }

                panel.style.x = entity.x + "px";
                panel.style.y = entity.y + "px";

                //panel.style.position = parseInt(realW * 100) + "% " + parseInt(realH * 100) + "% 0px";

                /*if (!panel.BHasClass("HeroMarkerTransition")) {
                    panel.AddClass("HeroMarkerTransition");
                }*/
            } else {
                var panel = $.CreatePanel("Label", mainPanel, "");
                /*panel.heroname = Entities.GetUnitName(entity.id);
                panel.heroimagestyle = "icon";*/
                panel.text = Players.GetPlayerName(GetUnitOwner(entity.id));
                panel.hittest = false;

                heroBars[entity.id] = panel;
            }
        })
        .value();

    var oldEntities = _.omit(heroBars, function(value, key) {
        return _.some(onScreen, function(entity) { return entity.id == key });
    });

    _.each(oldEntities, function(panel, key) {
        panel.DeleteAsync(0);
        delete heroBars[key];
    });
}

UpdateHeroBars();