--[[ 
I guess objective is to present one scene to start
start with sun, gradient background, gradient floor, with ripple effect?

need event handler and tweening library

--]]
require "emma/emma"  
require "emma/_shader"
require "emma/_matrix"


App = Class()

function App:init()
   print("\n\n\napp:init: ")
   self.objects = {}
 
--create default program
   local p = shader('default');--its ok this isnt released
   p:setAttribute('position');
   p:setUniform('modelViewProjectionMatrix');
   p.inputs.mvpm = p:getUniform('modelViewProjectionMatrix')
 
  local triangle = Em:new()
  table.insert(self.objects, triangle);
    
end
 

function App:update(delta)
  local a = RUNTIME / 100000
  r = (math.sin(a)* 127 + 128)  /255
  g = (math.sin(a + 255)* 127 + 128)  /255
  b = (math.sin(a + 100)* 127 + 128)  /255
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
    Em = nil  
    package.loaded['emma/_shader'] = nil
    package.loaded['emma/_matrix'] = nil 
    self.objects = nil
end
 
  
