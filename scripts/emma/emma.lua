--[[ Oh yeah app baby 

M = moveto
L = lineto
H = horizontal lineto
V = vertical lineto
C = curveto
S = smooth curveto
Q = quadratic Bézier curve
T = smooth quadratic Bézier curveto
A = elliptical Arc
Z = closepath

 <path d="M150 0 L75 200 L225 200 Z" />
--]]
foo = {
 
}


Em = Class()

function Em:init()

    self.vbo = {};
    self.vao = {};
    self.inputs = {}; 
    self.programs = {};

    --setup shader
    self:addProgram('default');

    -- make vao
    self:setVertexArray()

    -- create geometry
    self.geometry = {}
    self.geometry.mv = mat4();
    self.geometry.pr = mat4:CreateProjection(150, SCREEN.height/SCREEN.width, 0,1000);
end

function Em:addProgram(name)
    local p  = shader(name)
    _.push(self.programs, p);
end

function Em:setVertexArray()
    -- make vao
    self.vao[1] = gl.GenVertexArrays()
    gl.BindVertexArray(self.vao[1])
    
    -- make vbo
    self.vbo[1] = gl.GenBuffers()
    gl.BindBuffer(gl.ARRAY_BUFFER, self.vbo[1])
    
    -- copy verts
    --self:useSvg();
    --local data = array.new({1.0, -1.0, 1.0,  1.0, -1.0, 1.0,  1.0, 1.0, 1.0,  -1.0, 1.0, 1,  0}, 50);
    local data, obj = self:useGPC();  
    --print(inspect(data));
    data = array.new(data, 500);
    self.verts = gl.CopyData(data, array.len(data));
    
    -- attach data
    gl.BufferData(gl.ARRAY_BUFFER, 4 * 3 *  array.len(data), self.verts, gl.DYNAMIC_DRAW);
    
    -- point data to attrib input
    local p = self.programs[1];
    gl.EnableVertexAttribArray(p.inputs.position)
    gl.VertexAttribPointer(0,3, gl.FLOAT, gl.FALSE, 0,0)
    
    -- close vao
    gl.BindVertexArray(0)

   
end

function Em:debug()
    --draw out points here 
end

function Em:update(delta)
    local a = RUNTIME / 100000
    s = (math.sin(a) + 1)  /2
    local m = matrix:get('mv');
    local p = matrix:get('proj');
    m:assign(self.geometry.mv)
    m:multiply(3.0)   
    m:translate(-0.2,0.2, 0) ---(100*s)
    --m:translate(0,0, -100)-- (100*s)) ---
    p:assign(self.geometry.pr)
    p:multiply(m)
end 

function Em:extractSvg()
    
    -- Mesh: letter H
    local str = "M63.6,0 v206h238.2V0 h64.3v492.4h-64.3V261.5H63.6v230.9H0V0H63.6z"
    -- Mesh: Circle
    str = "M137.6,0c0,0,-110.1,298.9,-20.1,352.1 C229.1,418.1,419.6,193.9,137.6,0z"
    -- Mesh: wierd blob
    --str = "M597.3,561.9l-213.9-62.1 l-172.5,141 l-7-222.7 L16.5,297.6 l209.6-75.5 L282.7,6.7 c0,0,70.2,125.1,136.6,176 L641.7,170 L516.5,354.3 L597.3,561.9z"
 
    --split operations by spliting by letters
    local pattern = "(%D)(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*)%s?"
    
    local operations = {}
    for command, x1,y1,x2,y2,x3,y3  in string.gmatch(str, pattern) do
        if(command=="z" or command=="Z") then
            break
        end
        local d = {}
        d = {
            tonumber(x1) or 0,
            tonumber(y1) or 0,
            tonumber(x2) or 0,
            tonumber(y2) or 0,
            tonumber(x3)or 0,
            tonumber(y3) or 0 
        }
        d["command"] = command;
        _.push(operations, d)
    end
    print(inspect(operations))
    
    return operations;
end



function plottri(f,p, r,g,b, command)
    --if command=="stroke" then output(f,0,"setlinewidth") end
    --output(f,r,g,b,"setrgbcolor")
    

    
    for c=1,p:get() do
        
        local n=p:get(c)
        local x1,y1=p:get(c,1)
        local x2,y2=p:get(c,2)
        for i=3,n do
            local x,y=p:get(c,i)
            output(f,x1,y1,"moveto")
            output(f,x2,y2,"lineto")
            output(f,x,y,"lineto")
            --output(f,"closepath")
            x1,y1,x2,y2=x2,y2,x,y
        end
    end
end

function output(data, x, y, command)
      _.push(data, x)
      _.push(data, y)
      _.push(data, 0)
end

function normalizeOutput(data, w, h)
    -- normalize here
    local maxX = w or 800
    local maxY = h or 800
    local min  = 0
    -- inverse to follow top left origin
    for k,v in pairs(data) do
        local n = v --between 0 and 1
        if(k%3==1) then
            n = (v-min)/(maxX-min)
            n = ((n *2) -1)
            -- so zero x should be -1
        end
        if(k%3==2) then
            n = (v-min)/(maxY-min)
            n = -((n *2) -1)
            -- so zero y should be -1
        end
        
        data[k] = n
    end
end


function Em:useGPC()
    local verts = {
        1315 , 1282 ,
        1315 , 1329 ,
        1300 , 1314 ,
        1284 , 1345 ,
        1253 , 1312 ,
        1284 , 1298 ,
        1268 , 1282 ,
        1315 , 1282 
    };
     self:extractSvg()
    local obj = gpc.new():add(verts);
    local data = {};
    plottri(data, obj:strip(),0,0,0,0);
    normalizeOutput(data, 2000, 2000);
    return data, obj;
end

function Em:draw()
   
   local program = _.first(self.programs)
   program:use()
   
   gl.BindVertexArray(self.vao[1])
   gl.UniformMatrix4fv(program.inputs.mvpm, 1, 0, matrix:get('mv'));
   -- draw data
   gl.PointSize(4)
   gl.DrawArrays( gl.TRIANGLES ,0,80)
   
end



function Em:destroy()
    print('emma:destroy');
end
 
 return Em
