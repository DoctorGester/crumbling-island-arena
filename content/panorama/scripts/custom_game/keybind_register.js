function WrapFunction(name) {
    return function() {
        Game[name]();
    };
}

//Game.AddCommand("+EnterPressed", WrapFunction("OnEnterPressed"), "", 0);
//Game.AddCommand("-EnterPressed", function() {}, "", 0);