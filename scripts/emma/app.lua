--[[ Oh yeah app baby --]]
App = Class()

function App:init()
   print("\n\n\napp:init::::::::")
   self.objects = {}
   a = vec3(2,4,8.9)
   b = vec3()
   b:assign(a)  
   b.y= 9 
   
   --b.foo = 10   
   c = a * b
 print('vec test', c.y);       
end
 

function App:update(delta)
  local a = runtime / 100000
  r = (math.sin(a)* 127 + 128)  /255
  g = (math.sin(a + 255)* 127 + 128)  /255
  b = (math.sin(a + 100)* 127 + 128)  /255
  gl.ClearColor(r,g,b,1) 
  gl.Clear( gl.COLOR_BUFFER_BIT );
 
end
 
function App:draw()
 
end


function App:destroy()
    print('app:destroy');
end
 
 
