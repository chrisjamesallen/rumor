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
    {400,250},   
    {229,53},
    {243,68},
    {255,80},
    {262,98},
    {269,124},
    {272,140},
    {273,157},
    {273,173},
    {268,192},
    {263,211},
    {256,234},
    {249,258},
    {242,274},
    {238,290},
    {236,309},
    {235,334},
    {236,356},
    {244,376},
    {243,398},
    {248,414},
    {254,429},
    {268,448},
    {282,460},
    {301,472},
    {321,481},
    {337,482},
    {363,488},
    {386,490},
    {406,486},
    {426,478},
    {444,473},
    {458,469},
    {472,463},
    {483,461},
    {497,455},
    {512,449},
    {521,441},
    {530,433},
    {534,423},
    {533,408},
    {532,396},
    {534,386},
    {536,375},
    {537,365},
    {542,350},
    {547,340},
    {547,328},
    {546,316},
    {543,303},
    {545,292},
    {554,279},
    {558,268},
    {566,254},
    {571,243},
    {570,233},
    {560,229},
    {554,226},
    {549,221},
    {548,211},
    {546,204},
    {547,192},
    {543,186},
    {542,182},
    {540,177},
    {536,170},
    {533,166},
    {532,158},
    {534,148},
    {530,136},
    {528,125},
    {524,117},
    {507,108},
    {494,104},
    {482,104},
    {471,102},
    {465,95},
    {458,88},
    {444,76},
    {444,68},
    {436,53},
    {229,53}

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
    self:takeSvg();
    --data = array.new({1.0, -1.0, 1.0,  1.0, -1.0, 1.0,  1.0, 1.0, 1.0,  -1.0, 1.0, 1,  0}, 50);
    data = array.new(self.data_, 500); 
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

function Em:takeSvg()
    --M150 0 L75 200 L225 200 Z
    local str = "M150 0 L75 200 L225 200 Z"
    str = "M63.6,0 v206h238.2V0 h64.3v492.4h-64.3V261.5H63.6v230.9H0V0H63.6z"   
    str = "M63.6,0 v206h238.2V0 h64.3v492.4h-64.3V261.5H63.6v230.9H0V0H63.6z"   
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
        d[1] = tonumber(b)
        d[2] = tonumber(c) 
        _.push(operations, d)
    end  

    self.data_ = {};
    self.pos_ = {};
    self.startPos = {};
    _.each(operations , function(i) 
        if i.command == 'M' then self:moveTo(i[1],i[2]) end
        if i.command == 'L' then self:lineTo(i[1],i[2], i.command) end
        if i.command == 'i' then self:lineToRelative(i[1],i[2],i.command) end

        if i.command == 'h' then self:lineToRelative(i[1],0,i.command) end
        if i.command == 'H' then self:lineTo(i[1],self.pos_[2],i.command) end -- y param

        if i.command == 'v' then self:lineToRelative(0,i[1],i.command) end
        if i.command == 'V' then self:lineTo(self.pos_[1],i[1],i.command) end -- x param
    end)  

    self:closePath();

end

function Em:moveTo(x,y)
    if(self.pos_.started == nil) then
        self.pos_.started = true
        self.startPos.x = x;
        self.startPos.y = y;
    end
    self.pos_[1] = x;
    self.pos_[2] = y; 
    self:lineTo(x,y)  
end

function Em:lineTo(x,y,r)
    --print(r,x,y)
    --print('\npoint',r,x,y)
    _.push(self.data_,{x, y, 0})
    self.pos_[1] = x;
    self.pos_[2] = y; 
end

function Em:lineToRelative(x,y,r)
   -- print('\nrel',r,x,y)
    --print(r,x,y)
    self.pos_[1] = self.pos_[1] + x
    self.pos_[2] = self.pos_[2] + y
    _.push(self.data_,{self.pos_[1], self.pos_[2], 0})
end


function Em:closePath()
     
    -- self.data_ = { 
    --  0, 0, 0 
    -- } 
    --for v,k in pairs(self.data_) do print(v) end
    --normalize

    self:lineTo(self.startPos.x,self.startPos.y)
    print(inspect(self.data_))
   -- for v,k in pairs(foo) do foo[v][3] = 0 end
    self.data_ = _.flatten(self.data_)
    local maxX = 1900
    local maxY = 1120
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
    print('data>>>')
    
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
    gl.PointSize(5) 
    gl.DrawArrays( gl.TRIANGLE_FAN ,0,60) 
 --_.each(self.programs,function(program)
 --  end)
end

function Em:destroy()
    print('emma:destroy');
end
 
 return Em
