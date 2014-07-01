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
    self:takeSvg();
    --data = array.new({1.0, -1.0, 1.0,  1.0, -1.0, 1.0,  1.0, 1.0, 1.0,  -1.0, 1.0, 1,  0}, 50);
    data = array.new(self.data_, 50);
    self.verts = gl.CopyData(data, array.len(data));
    
    -- attach data
    gl.BufferData(gl.ARRAY_BUFFER, 4 * 3 * 4, self.verts, gl.DYNAMIC_DRAW);
    
    -- point data to attrib input
    local p = self.programs[1];
    gl.EnableVertexAttribArray(p.inputs.position)
    gl.VertexAttribPointer(0,3, gl.FLOAT, gl.FALSE, 0,0)
    
    -- close vao
    gl.BindVertexArray(0)

   
end

function Em:takeSvg()
    --M150 0 L75 200 L225 200 Z
    local str = "M150 0 L75 200 L225 200 Z"
    str = "M355.6,294.7v206h238.2v-206h64.3v492.4h-64.3V556.2H355.6v230.9h-63.6V294.7H355.6z"
    local operations = {}
    --split operations by spliting by letters
    local pattern="(%D)([0-9]*)%s([0-9]*)%s"
    pattern = "(%D)(-?[0-9]*.?[0-9]*),?%s?(-?[0-9]*.?[0-9]*)%s?"
    pattern = "(%D)(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*)%s?"
    for a,b,c in string.gmatch(str, pattern) do
        if(a=="z" or a=="Z") then
            break
        end
        local d = {}
        d["command"] = a;
        d[1] = b
        d[2] = c
        _.push(operations, d)
        print(d[2])
    end

    self.data_ = {};
    self.pos_ = {};

    _.each(operations , function(i) 
        if i.command == 'M' then self:moveTo(i[1],i[2]) end
        if i.command == 'L' then self:lineTo(i[1],i[2], i.command) end
        if i.command == 'i' then self:lineToRelative(i[1],i[2],i.command) end

        if i.command == 'V' then self:lineTo(self.pos_[1],i[1],i.command) end -- y param
        if i.command == 'v' then self:lineToRelative(0,i[1],i.command) end

        if i.command == 'H' then self:lineTo(i[1],self.pos[2],i.command) end -- x param
        if i.command == 'h' then self:lineToRelative(i[1],0,i.command) end
    end)  

    self:closePath();
  --  for i in pairs(words) do print(words[i]) end  

end

function Em:moveTo(x,y)
    self.pos_[1] = x;
    self.pos_[2] = y;      
end

function Em:lineTo(x,y,r)
    print(y)
    _.push(self.data_,x)
    _.push(self.data_,y)
    _.push(self.data_,0) --z
    self.pos_[1] = x;
    self.pos_[2] = y; 
end

function Em:lineToRelative(x,y,r)
    print(r,y)
    self.pos_[1] = self.pos_[1] + x
    self.pos_[2] = self.pos_[2] + y
    _.push(self.data_,self.pos_[1])
    _.push(self.data_,self.pos_[2])
    _.push(self.data_,0) --z

end


function Em:closePath()
    -- self.data_ = { 
    -- 150, 0, 0,
    -- 75, 200,0,
    -- 225, 200,0     
    -- }
    print('foo')
    for v,k in pairs(self.data_) do print(v) end
    --normalize
    local maxX = 1900
    local maxY = 1600
    local min  = 0
    -- inverse to follow top left origin
    for k,v in pairs(self.data_) do  
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
        
        self.data_[k] = n
        --print(k,self.data_[k])
    end
 
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
    m:translate(0,0, 0) ---(100*s) 
    p:assign(self.geometry.pr)
    p:multiply(m)
end
 
function Em:draw()
    -- use correct shader
    --print(tablelength(self.programs))
    local program = _.first(self.programs);
    program:use()
    -- bind vao
    gl.BindVertexArray(self.vao[1])
    gl.UniformMatrix4fv(program.inputs.mvpm, 1, 0, matrix:get('mv'));
    -- draw data
    gl.PointSize(10) 
    gl.DrawArrays(gl.TRIANGLES,0,3) 
 --_.each(self.programs,function(program)
 --  end)


end

function Em:destroy()
    print('emma:destroy');
end
 
 return Em
