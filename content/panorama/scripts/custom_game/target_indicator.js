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
        var to = UpdateLine(this.particle, this.unit, this.data, cursor);
        var result = to.minus(Vector.FromArray(Entities.GetAbsOrigin(unit))).normalize().scale(150).add(to);
        Particles.SetParticleControl(this.particle, 2, result);
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
            var result = cursor.minus(pos).normalize().scale(this.offset).add(pos);

            Particles.SetParticleControl(this.particle, 0, result);
        }
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_THICK_LINE"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/thick_line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.Update = function(cursor){
        UpdateLine(this.particle, this.unit, this.data, cursor);

        Particles.SetParticleControl(this.particle, 2, [ GetNumber(data.Width, 0, this.unit), 0, 0 ]);
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_CONE"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/cone.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.Update = function(cursor){
        UpdateLine(this.particle, this.unit, this.data, cursor);

        Particles.SetParticleControl(this.particle, 2, [ GetNumber(data.Width, 0, this.unit), 0, 0 ]);
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};


indicatorTypes["TARGETING_INDICATOR_HALF_CIRCLE"] = function(data, unit) {
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/half_circle.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.Update = function(position){
        Particles.SetParticleControl(this.particle, 1, position);
        Particles.SetParticleControl(this.particle, 2, [ GetNumber(data.Radius, 0, this.unit), 0, 0 ]);
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_LINE_EMBER"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.FindRemnant = function(){
        for (var unit of Entities.GetAllEntitiesByName(Entities.GetUnitName(this.unit))) {
            // There is no Entities.GetOwnerPlayer. Sad.
            if (unit != this.unit && Entities.IsCommandRestricted(unit) && Entities.GetTeamNumber(unit) == Players.GetTeam(Players.GetLocalPlayer())) {
                return unit;
            }
        }

        return null;
    }

    var remnant = this.FindRemnant();
    if (remnant != null) {
        this.remnant = remnant;
        this.remnantParticle = Particles.CreateParticle("particles/targeting/line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, remnant);
    }

    this.Update = function(cursor){
        var to = UpdateLine(this.particle, this.unit, this.data, cursor);
        var result = to.minus(Vector.FromArray(Entities.GetAbsOrigin(unit))).normalize().scale(150).add(to);
        Particles.SetParticleControl(this.particle, 2, result);

        if (this.remnantParticle && this.remnant) {
            var to = UpdateLine(this.remnantParticle, this.remnant, this.data, cursor);
            var result = to.minus(Vector.FromArray(Entities.GetAbsOrigin(this.remnant))).normalize().scale(150).add(to);
            Particles.SetParticleControl(this.remnantParticle, 2, result);
        }
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);

        if (this.remnantParticle) {
            Particles.DestroyParticleEffect(this.remnantParticle, false);
            Particles.ReleaseParticleIndex(this.remnantParticle);
        }
    }
};

indicatorTypes["TARGETING_INDICATOR_TINKER_LASER"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/thick_line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);

    this.Update = function(cursor){
        UpdateLine(this.particle, this.unit, this.data, cursor);

        var pos = Vector.FromArray(Entities.GetAbsOrigin(unit));
        var forward = Vector.FromArray(Entities.GetForward(unit));

        Particles.SetParticleControl(this.particle, 0, pos.add(new Vector(forward.y, -forward.x, 0).scale(96)))
        Particles.SetParticleControl(this.particle, 2, [ GetNumber(data.Width, 0, this.unit), 0, 0 ]);
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

function UpdateLine(particle, unit, data, cursor) {
    var pos = Vector.FromArray(Entities.GetAbsOrigin(unit));
    var to = Vector.FromArray(cursor);

    var length = to.minus(pos).length();
    var newLength = Clamp(length, GetNumber(data.MinLength, 0, unit), GetNumber(data.MaxLength, Number.MAX_VALUE, unit));

    if (length != newLength) {
        length = newLength;
        to = to.minus(pos).normalize().scale(length).add(pos);
    }

    Particles.SetParticleControl(particle, 1, to);

    return to;
}

indicatorTypes["TARGETING_INDICATOR_DUSA_SNAKE"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/dusa_snake.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.Update = function(cursor){
        var to = Vector.FromArray(cursor);
        var dir = to.minus(Vector.FromArray(Entities.GetAbsOrigin(unit))).normalize();
        var pos = Vector.FromArray(Entities.GetAbsOrigin(unit));
        var to = Vector.FromArray(cursor);

        var length = to.minus(pos).length();
        var newLength = Clamp(length, GetNumber(data.MinLength, 0, unit), GetNumber(data.MaxLength, Number.MAX_VALUE, unit));

        if (length != newLength) {
            length = newLength;
            to = to.minus(pos).normalize().scale(length).add(pos);
        }

        Particles.SetParticleControl(this.particle, 1, to);
        Particles.SetParticleControl(this.particle, 2, to.add(dir.scale(150).rotate2d(-0.75)));
        Particles.SetParticleControl(this.particle, 3, to.minus(pos).normalize().scale(length / 2).add(pos));

        Particles.SetParticleControlForward(this.particle, 3, [dir.y, -dir.x, 0])
        Particles.SetParticleControlForward(this.particle, 1, [dir.y, -dir.x, 0])
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

        var facing = Vector.FromArray(Entities.GetForward(unit)).scale(1, 1, 0).normalize(); // Yay!
        var result = pos.add(facing.scale(1000));

        hoverIndicator.Update(result);
    }
}

function UpdateTargetIndicator(){
    $.Schedule(0.01, UpdateTargetIndicator);

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

        if (data && data.Type) {
            indicator = new indicatorTypes[data.Type](data, unit);
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

            if (hoverData && hoverData.Type) {
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
