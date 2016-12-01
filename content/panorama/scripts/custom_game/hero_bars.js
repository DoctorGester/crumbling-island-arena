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

function multiply(a, b) {
    var aNumRows = a.length, aNumCols = a[0].length,
        bNumRows = b.length, bNumCols = b[0].length,
        m = new Array(aNumRows);  // initialize array of rows
    for (var r = 0; r < aNumRows; ++r) {
        m[r] = new Array(bNumCols); // initialize the current row
        for (var c = 0; c < bNumCols; ++c) {
            m[r][c] = 0;             // initialize the current cell
            for (var i = 0; i < aNumCols; ++i) {
                m[r][c] += a[r][i] * b[i][c];
            }
        }
    }
    return m;
}
function multiply(m1, m2) {
    var result = [];
    for (var i = 0; i < m1.length; i++) {
        result[i] = [];
        for (var j = 0; j < m2[0].length; j++) {
            var sum = 0;
            for (var k = 0; k < m1[0].length; k++) {
                sum += m1[i][k] * m2[k][j];
            }
            result[i][j] = sum;
        }
    }
    return result;
}
function multiplyMatrixAndPoint(matrix, point) {

    //Give a simple variable name to each part of the matrix, a column and row number
    var c0r0 = matrix[ 0], c1r0 = matrix[ 1], c2r0 = matrix[ 2], c3r0 = matrix[ 3];
    var c0r1 = matrix[ 4], c1r1 = matrix[ 5], c2r1 = matrix[ 6], c3r1 = matrix[ 7];
    var c0r2 = matrix[ 8], c1r2 = matrix[ 9], c2r2 = matrix[10], c3r2 = matrix[11];
    var c0r3 = matrix[12], c1r3 = matrix[13], c2r3 = matrix[14], c3r3 = matrix[15];

    //Now set some simple names for the point
    var x = point[0];
    var y = point[1];
    var z = point[2];
    var w = point[3];

    //Multiply the point against each part of the 1st column, then add together
    var resultX = (x * c0r0) + (y * c0r1) + (z * c0r2) + (w * c0r3);

    //Multiply the point against each part of the 2nd column, then add together
    var resultY = (x * c1r0) + (y * c1r1) + (z * c1r2) + (w * c1r3);

    //Multiply the point against each part of the 3rd column, then add together
    var resultZ = (x * c2r0) + (y * c2r1) + (z * c2r2) + (w * c2r3);

    //Multiply the point against each part of the 4th column, then add together
    var resultW = (x * c3r0) + (y * c3r1) + (z * c3r2) + (w * c3r3);

    return [resultX, resultY, resultZ, resultW]
}
function multiplyMatrices(matrixA, matrixB) {

    // Slice the second matrix up into columns
    var column0 = [matrixB[0], matrixB[4], matrixB[8], matrixB[12]];
    var column1 = [matrixB[1], matrixB[5], matrixB[9], matrixB[13]];
    var column2 = [matrixB[2], matrixB[6], matrixB[10], matrixB[14]];
    var column3 = [matrixB[3], matrixB[7], matrixB[11], matrixB[15]];

    // Multiply each column by the matrix
    var result0 = multiplyMatrixAndPoint( matrixA, column0 );
    var result1 = multiplyMatrixAndPoint( matrixA, column1 );
    var result2 = multiplyMatrixAndPoint( matrixA, column2 );
    var result3 = multiplyMatrixAndPoint( matrixA, column3 );

    // Turn the result columns back into a single matrix
    return [
        result0[0], result1[0], result2[0], result3[0],
        result0[1], result1[1], result2[1], result3[1],
        result0[2], result1[2], result2[2], result3[2],
        result0[3], result1[3], result2[3], result3[3]
    ]
}
function projM() {
    var aspectRatio = 1920.0 / 1080.0;
    var zNear = 1;
    var zFar = 1000;
    var zRange = zFar - zNear;
    var fov = Math.tan(Math.PI / 4.0);

    return [
        1.0 / (fov * aspectRatio), 0, 0, 0,
        0, 1.0 / fov, 0, 0,
        0, 0, (-zNear - zFar) / zRange, 2 * zFar * zNear / zRange,
        0, 0, 1, 0
    ]
}

function trM(pos) {
    return [
        1, 0, 0, pos[0],
        0, 1, 0, pos[1],
        0, 0, 1, pos[2],
        0, 0, 0, 1
    ]
}

function cM() {
    return [
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, pos[2],
        0, 0, 0, 1
    ]
}

function lookAt(eye, target, up) {
    eye = Vector.FromArray(eye);
    target = Vector.FromArray(target);
    up = Vector.FromArray(up);

    var zaxis = eye.minus(target).normalize();    // The "forward" vector.
    var xaxis = up.cross(zaxis).normalize();// The "right" vector.
    var yaxis = zaxis.cross(xaxis);     // The "up" vector.

    // Create a 4x4 view matrix from the right, up, forward and eye position vectors
    return [
        xaxis.x, yaxis.x, zaxis.x, 0,
        xaxis.y, yaxis.y, zaxis.y, 0,
        xaxis.z, yaxis.z, zaxis.z, 0,
        -xaxis.dot(eye), -yaxis.dot(eye), -zaxis.dot(eye), 1
    ];
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

            return { id: entity, x: x, y: y, abs: abs };
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
                    //entity.x -= panel.actuallayoutwidth / 2;
                }

                var camPos = GameUI.GetScreenWorldPosition(Game.GetScreenWidth() / 2, Game.GetScreenHeight() / 2);
                //multiplyMatrices(projM(), trM(entity.abs));

                var cam = lookAt([camPos[0], camPos[1] - 800, 1515], [camPos[0], camPos[1], 128], [0, 0, 1]);

                var mv = multiplyMatrices(projM(), cam);
                var mvp = multiplyMatrices(mv, trM(entity.abs));

                //var P = multiplyMatrixAndPoint(mv, [entity.abs[0], entity.abs[1], entity.abs[2], 0]);
                var pos = multiplyMatrixAndPoint(mvp, [entity.abs[0], entity.abs[1], entity.abs[2], 1]);
                //var pos = [mvp[0] / mvp[3], mvp[1] / mvp[3], mvp[2] / mvp[3]];
                //$.Msg(Math.floor(pos[0]) + " " + Math.floor(pos[1]));
                panel.style.x = Math.floor(pos[0]) + "px";
                panel.style.y = Math.floor(pos[1]) + "px";
//$.Msg(pos);
                //panel.style.position = parseInt(realW * 100) + "% " + parseInt(realH * 100) + "% 0px";

                /*if (!panel.BHasClass("HeroMarkerTransition")) {
                    panel.AddClass("HeroMarkerTransition");
                }*/
            } else {
                var panel = $.CreatePanel("Label", mainPanel, "");
                /*panel.heroname = Entities.GetUnitName(entity.id);
                panel.heroimagestyle = "icon";*/
                //panel.text = Players.GetPlayerName(GetUnitOwner(entity.id));
                panel.hittest = false;

                panel.style.width = "8px";
                panel.style.height = "8px";
                panel.style.backgroundColor = "red";

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