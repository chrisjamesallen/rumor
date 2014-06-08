print("emma")

Obj = {
    name = "base_object"
}
function Obj:new (o)
    o = o or {}
    print(self.name)
    setmetatable(o, self)
    self.__index = self
    o:init()
    return o
end

function Obj:extend (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.__super = self
    return o
end

function Obj:init ()
    self.name = "obj"
    print("Hi Im " .. self.name)
end

function Obj:test ()
    print("Hi Im " .. self.name)
end



Emma = Obj:extend()

function Emma:init()
    self.__super:init()
    self.name = "Emma"
    print("Hi Im " .. self.name)
end



Chris = Emma:extend()
function Chris:init()
    self.__super:init()
    self.name =  "Chris"
    print("Hi Im " .. self.name)
end

 

 