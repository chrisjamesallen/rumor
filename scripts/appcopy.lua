--[[ Oh yeah app baby --]]
App = Class()

function App:init()
   print("\n\n\napp:init::::::::")
   self.objects = {}
   local triangle = Emma:new()
   table.insert(self.objects, triangle);
end



function App:update(delta)
  local a = runtime / 100000
  r = (math.sin(a)* 127 + 128)  /255
  g = (math.sin(a + 255)* 127 + 128)  /255
  b = (math.sin(a + 100)* 127 + 128)  /255
  gl.ClearColor(r,g,b,1) 
  gl.Clear( gl.COLOR_BUFFER_BIT );
  triangle = self.objects[1]
  triangle:update(delta)
end
 
function App:draw()
    local triangle = self.objects[1]
    triangle:draw()
end


function App:destroy()
    print('app:destroy');
end


squark = Class();

function squark:init()
    self.state= {}
    self.state.mv= mat4()
    self.state.proj= mat4()
    print("squarkwww");
    self:set('mv');
    self:identity();
end

function squark:set(state)
    if(state == "mv") then
        self.curState = self.state.mv
    end
    if(state == "proj") then
        self.curState = self.state.proj
    end
    return self.curState
end

function squark:get(state)
    local s
    if(state == "mv") then
        s = self.state.mv
    end
    if(state == "proj") then
        s = self.state.proj
    end
    return s
end

function squark:assign(m)
    self.curState:assign(m)
end

function squark:multiply(m)
    self.curState:multiply(m)
end

function squark:translate(x,y,z)
    self.curState:translate(x,y,z) 
end

function squark:identity()
    self.curState:identity()
end

squark:init()


--Emma Class Object

--Constructor
function emma()
    return Emma:new();
end

--Class
Emma= Class()

function Emma:init()
    local b = self.__index
    b.__gc = self.destroy
    setmetatable(self, b)
    self.vbo = {};
    self.vao = {};
    self.inputs = {};
    local screen = System.screen();

    --setup shader
    self.program = shader('default');
    self.program:setAttribute('position');
    self.program:setUniform('modelViewProjectionMatrix');
    self.program.inputs.mvpm = self.program:getUniform('modelViewProjectionMatrix')

    print(" ", self.program.inputs.position, self.program.inputs.mvpm);
    -- make vao
    self.vao[1] = gl.GenVertexArrays()
    gl.BindVertexArray(self.vao[1])
    -- make vbo
    self.vbo[1] = gl.GenBuffers()
    gl.BindBuffer(gl.ARRAY_BUFFER, self.vbo[1])
    -- copy verts
    data = array.new({1.0, -1.0, 1.0,  1.0, -1.0, 1.0,  1.0, 1.0, 1.0,  -1.0, 1.0, 1,  0}, 50);
    self.verts = gl.CopyData(data, array.len(data));
    -- attach data
    gl.BufferData(gl.ARRAY_BUFFER, 4 * 3 * 4, self.verts, gl.STATIC_DRAW);
    -- point data to attrib input
    gl.EnableVertexAttribArray(self.program.inputs.position)
    gl.VertexAttribPointer(0,3,gl.FLOAT, gl.FALSE, 0,0)
    gl.BindVertexArray(0)
    -- create geometry
    self.geometry = {}
    
    self.geometry.mv = mat4();
    self.geometry.pr = mat4:CreateProjection(150, screen.height/screen.width, 0,1000);
    --self.geometry.mvp = self.geometry.pr * self.geometry.mv;
    --self.geometry.scale = self.geometry.mv * 0.5;--mat4:Scale(0.5,0.5,0.5)
    --self.geometry.test = self.geometry.scale * self.geometry.mv;
end

function Emma:update()
    local a = runtime / 100000
    s = (math.sin(a) + 1)  /2
    squark:set('mv');
    squark:assign(self.geometry.mv)
    squark:translate(0,0, -(100*s)) 
    squark:set('proj');
    squark:assign(self.geometry.pr)
    squark:multiply(squark:get('mv'))
    squark:set('mv');  
end  



function Emma:draw()
    
    -- use correct shader
    self.program:use();
    -- bind vao
    gl.BindVertexArray(self.vao[1]) 
    gl.UniformMatrix4fv(self.program.inputs.mvpm, 1, 0, squark:get('proj'));
    -- draw data
    gl.DrawArrays(gl.TRIANGLE_STRIP,0,4)  
end

function Emma:destroy()
    print("destroy:emma");
    -- tear stuff down
    --gl.ClearData(self.verts);
end

 


-- Mesh Object
function mesh()
    return Mesh:new();
end

--Class
Mesh= Class()

function Mesh:init()
    local b = {__index = getmetatable("_Emma")}
    b.__gc = self.destroy;
    setmetatable(self, b)
end

function Mesh:update()
    
end

function Mesh:draw()
    
end

function Mesh:destroy()
    print("destroy:mesh");
end


-- Geometry Object
function Geometry()
    return Geometry:new();
end

--Class
Geometry= Class()

function Geometry:init()
    local b = {__index = getmetatable("_Emma")}
    b.__gc = self.destroy;
    setmetatable(self, b)
end

function Geometry:update()
    
end

function Geometry:draw()
    
end

function Geometry:destroy()
    print("destroy:geometry");
end




-- Material Object
function Material()
    return Material:new();
end

--Class
Material= Class()

function Material:init()
    local b = {__index = getmetatable("_Emma")}
    b.__gc = self.destroy;
    setmetatable(self, b)
end

function Material:update()
    
end

function Material:draw()
    
end

function Material:destroy()
    print("destroy:emma");
end


