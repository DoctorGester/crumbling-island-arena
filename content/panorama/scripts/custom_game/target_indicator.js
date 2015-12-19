var dummy = "npc_dota_hero_wisp";
var indicator = null;
var lastAbility = -1;
var hoverAbility = -1;
var lastHoverAbility = -1;
var targetingIndicators = {};
var hoverIndicators = {};
var indicatorTypes = {};
var hoverTypes = {};
var hoverIndicator = null;

function GetNumber(value, or, unit) {
    if (!value) {
        return or;
    }

    if (IsNumeric(value)) {
        return value;
    }

    return eval(value);
}

indicatorTypes[null] = function(data, unit) {
    this.Update = function(position){}
    this.Delete = function(){}
};

indicatorTypes["TARGETING_INDICATOR_DIRECTION_GLOBAL"] = function(data, unit) {
    this.particle = Particles.CreateParticle("particles/targeting/global_target.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.Update = function(position){
        Particles.SetParticleControl(this.particle, 1, position);
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_LINE"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.Update = function(cursor){
        var pos = Vector.FromArray(Entities.GetAbsOrigin(this.unit));
        var to = Vector.FromArray(cursor);

        var length = to.minus(pos).length();
        var newLength = Clamp(length, GetNumber(this.data.MinLength, 0, this.unit), GetNumber(this.data.MaxLength, Number.MAX_VALUE, this.unit));

        if (length != newLength) {
            length = newLength;
            to = to.minus(pos).normalize().scale(length).add(pos);
        }

        Particles.SetParticleControl(this.particle, 1, to);
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_AOE"] = function(data, unit) {
    this.particle = Particles.CreateParticle("particles/targeting/aoe.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);
    Particles.SetParticleControl(this.particle, 1, [ GetNumber(data.Radius, 0, unit), 0, 0 ]);

    this.Update = function(position){
        Particles.SetParticleControl(this.particle, 0, position);
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_RANGE"] = function(data, unit) {
    this.offset = GetNumber(data.Offset, 0, unit);
    this.unit = unit;

    var attach = ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW;

    if (this.offset) {
        attach = ParticleAttachment_t.PATTACH_ABSORIGIN;
    }

    this.particle = Particles.CreateParticle("particles/targeting/range.vpcf", attach, unit);

    this.Update = function(cursor){
        Particles.SetParticleControl(this.particle, 1, [ GetNumber(data.Radius, 0, this.unit), 0, 0 ]);

        if (this.offset) {
            var pos = Vector.FromArray(Entities.GetAbsOrigin(this.unit));
            var to = Vector.FromArray(cursor);
            var result = to.minus(pos).normalize().scale(1, 1, 0).scale(this.offset).add(pos);

            Particles.SetParticleControl(this.particle, 0, result);
        }
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

function UpdatePosition() {
    var cursor = GameUI.GetCursorPosition();
    var position = GameUI.GetScreenWorldPosition(cursor);

    if (position && indicator) {
        indicator.Update(position);
    }
}

function UpdateHoverPosition() {
    var unit = Players.GetLocalPlayerPortraitUnit();
    var pos = Entities.GetAbsOrigin(unit);

    if (pos && hoverIndicator) {
        pos = Vector.FromArray(pos);

        var facing = new Vector(0.4, 0.4, 0).normalize().scale(1, 1, 0); // I'm crying
        var result = pos.add(facing.scale(this.offset));

        hoverIndicator.Update(result);
    }
}

function UpdateTargetIndicator(){
    $.Schedule(0.025, UpdateTargetIndicator);

    var unit = Players.GetLocalPlayerPortraitUnit();
    var active = Abilities.GetLocalPlayerActiveAbility();
    var newHover = hoverAbility;
    var data = targetingIndicators[Abilities.GetAbilityName(active)];

    if (active != lastAbility) {
        lastAbility = active;

        if (indicator) {
            indicator.Delete();
            indicator = null;
        }

        if (data) {
            var type = data.Type;

            indicator = new indicatorTypes[type](data, unit);
            UpdatePosition(); // It's a bug, blame valve
        }
    } else {
        UpdatePosition();
    }

    if (data && (data.DisplayRange == "1" || data.DisplayRange == "true")) {
        newHover = active;
    }

    if (lastHoverAbility != newHover) {
        lastHoverAbility = newHover;

        if (hoverIndicator) {
            hoverIndicator.Delete();
            hoverIndicator = null;
        }

        if (newHover != -1) {
            var hoverData = hoverIndicators[Abilities.GetAbilityName(newHover)];

            if (hoverData) {
                hoverIndicator = new indicatorTypes[hoverData.Type](hoverData, unit);
                UpdateHoverPosition();
            }
        }
    } else {
        UpdateHoverPosition();
    }
}

function SetCurrentHoverSpell(spell){
    if (spell) {
        hoverAbility = spell.id;
    } else {
        hoverAbility = -1;
    }
}

UpdateTargetIndicator();

SubscribeToNetTableKey("main", "targetingIndicators", true, function(data){
    targetingIndicators = data;
});

SubscribeToNetTableKey("main", "hoverIndicators", true, function(data){
    hoverIndicators = data;
});
