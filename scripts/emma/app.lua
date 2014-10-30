
require "emma/emma"
require "emma/_shader"
require "emma/_matrix"
require "emma/svg"

App = Class()

function App:init()
    print("\n\n\n------------------------------------------------")
    print("app init ")
    self.objects = {}
    --create default program
    local p = shader('default'); --its ok this isnt released
    p:setAttribute('position');
    p:setUniform('modelViewProjectionMatrix');
    p.inputs.mvpm = p:getUniform('modelViewProjectionMatrix')
    --set system wide stuff
    self.system = {}
    self.system.screen = System.screen()
    local triangle = Em:new()
    table.insert(self.objects, triangle);
end


function App:update(delta)
    local a =  app.system.runTime / 1000000000;
    local r = (math.sin(a) * 127 + 128) / 255
    local g = (math.sin(a + 255) * 127 + 128) / 255
    local b = (math.sin(a + 100) * 127 + 128) / 255
    gl.ClearColor(r, g, b,1)
    gl.Clear(gl.COLOR_BUFFER_BIT);
    local triangle = self.objects[1]
    triangle = self.objects[1]
    triangle:update(delta)
end

function App:draw()
    local triangle = self.objects[1]
    triangle:draw()
end


function App:destroy()
    --_.each(_.keys(package.loaded), print)          
    self.objects = nil
    Em = nil
end

function AppDestroy()
    package.loaded['emma/emma'] = nil
    package.loaded['emma/_shader'] = nil
    package.loaded['emma/_matrix'] = nil
    package.loaded['emma/svg_main'] = nil
    package.loaded['emma/svg_hull'] = nil
    package.loaded['emma/svg_curves'] = nil
    package.loaded['emma/svg'] = nil

end

return App;
