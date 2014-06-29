-- global mat4 to reduce gc overhead

matrix = mat4();

function matrix:init()
    self.state= {}
    self.state.mv= mat4()
    self.state.proj= mat4()
    self:set('mv');
    self:identity();
end

function matrix:set(state)

    if(state == "mv") then
        self.curState = self.state.mv
    end
    if(state == "proj") then
        self.curState = self.state.proj
    end
    return self.curState
end

function matrix:get(state)
    local s

    if(state == "mv") then
        s = self.state.mv
    end
    if(state == "proj") then
        s = self.state.proj
    end
    return s
end

matrix:init()
 