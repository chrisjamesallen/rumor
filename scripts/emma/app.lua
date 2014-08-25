--[[ 
I guess objective is to present one scene to start
start with sun, gradient background, gradient floor, with ripple effect?

need event handler and tweening library

--]]
require "emma/emma"  
require "emma/_shader"
require "emma/_matrix"
require "emma/svg"

App = Class()

function App:init()
   print("\n\n\napp init ")
   self.objects = {}

   --create default program
   local p = shader('default');--its ok this isnt released
   p:setAttribute('position');
   p:setUniform('modelViewProjectionMatrix');
   p.inputs.mvpm = p:getUniform('modelViewProjectionMatrix')

 self.system = {}
     self.system.screen = System.screen()
  local triangle = Em:new()
  table.insert(self.objects, triangle);
    
end


function App:update(delta)
  local a = delta --RUNTIME / 100000 
  local r = (math.sin(a)* 127 + 128)  /255
  local g = (math.sin(a + 255)* 127 + 128)  /255
  local b = (math.sin(a + 100)* 127 + 128)  /255
  gl.ClearColor(r,g,b,1)
  gl.Clear( gl.COLOR_BUFFER_BIT );
   local triangle = self.objects[1]
    triangle = self.objects[1]
  triangle:update(delta)
 
end
 
function App:draw()
  -- lets draw objects 
   local triangle = self.objects[1]
   triangle:draw()
end


function App:destroy()
    --_.each(_.keys(package.loaded), print)          
    package.loaded['emma/emma'] = nil
    package.loaded['emma/_shader'] = nil
    package.loaded['emma/_matrix'] = nil
    package.loaded['emma/svg'] = nil
    package.loaded['emma/app'] = nil
    self.objects = nil
    print("app:destroy!")
    Em = nil
end
 
  
return App;
