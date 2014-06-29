
Obj = {
    name = "base_object"
}

function obj (o)
    return Obj:new(o)
end

function Class(o)
    return Obj:extend(o)
end

function Obj:new (o)
    o = o or {}
    self.__index = self
    self.__gc = self.destroy
    setmetatable(o, self)
    o:init()
    return o
end

function Obj:init ()
    self.name = "class"
end

function Obj:extend (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.__super = self
    return o
end

function Obj:destroy ()
     print("Obj_:destroy")
end


-- other helper methods

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function bind(target, func)
    local s = {}
    setmetatable(s, target);
    s.__index = target;
    s.test = func
    return function()
        s:test()
    end
end


