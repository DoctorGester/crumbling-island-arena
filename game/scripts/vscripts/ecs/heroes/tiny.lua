function TinyComponent()
    local base = ModelCheckerComponent()

    return WrapComponent({
        HasModelChanged = function(self)
            return self:GetUnit():GetModelName() ~= "models/heroes/tiny_04/tiny_04.vmdl" and base.HasModelChanged(self)
        end
    })
end