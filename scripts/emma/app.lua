--[[ 
I guess objective is to present one scene to start
start with sun, gradient background, gradient floor, with ripple effect?

need event handler and tweening library

--]]
require "emma/_shader"
require "emma/_matrix"


App = Class()

function App:init()
   print("\n\n\napp:init::::::::")
   self.objects = {}
 
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
    print('app:destroy');
end
 
  
