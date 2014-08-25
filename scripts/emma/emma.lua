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
foo = {}


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
     print('domeghjg ')

    -- create geometry
    self.geometry = {}
    self.geometry.mv = mat4();
    self.geometry.pr = mat4:CreateProjection(150, System.screen().height / System.screen().width, 0, 1000);
end

function Em:addProgram(name)
    local p = shader(name)
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
    --local data = array.new({1.0, -1.0, 1.0,  1.0, -1.0, 1.0,  1.0, 1.0, 1.0,  -1.0, 1.0, 1,  0}, 50);
    local svg = SVG:new();
    local data = svg:extractSvg();
    data = array.new(data, 500);
    self.verts = gl.CopyData(data, array.len(data));

    -- attach data
    gl.BufferData(gl.ARRAY_BUFFER, 4 * 3 * array.len(data), self.verts, gl.DYNAMIC_DRAW);

    -- point data to attrib input
    local p = self.programs[1];
    gl.EnableVertexAttribArray(p.inputs.position)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, 0)
  
    -- close vao
    gl.BindVertexArray(0)
end

function Em:debug()
    --draw out points here 
end
      
function Em:update(delta)
    local a = app.system.runTime / 100000
    s = (math.sin(a) + 1) / 2
    local m = matrix:get('mv');
    local p = matrix:get('proj');
    m:assign(self.geometry.mv)
    m:multiply(3.0)
    m:translate(-0.2, 0.2, 0) --- (100*s)
    -- m:translate(0,0, -100)-- (100*s)) ---
    p:assign(self.geometry.pr)
    p:multiply(m)
end




function Em:draw()

    local program = _.first(self.programs)
    program:use()

    gl.BindVertexArray(self.vao[1])
    gl.UniformMatrix4fv(program.inputs.mvpm, 1, 0, matrix:get('mv'));
    -- draw data
    gl.PointSize(4)
    gl.DrawArrays(gl.TRIANGLES, 0, 80)
end


function Em:convertSvg(operations)
    _.each(operations, function(i)
        if i.command == 'M' then self:moveTo(i[1], i[2]) end
        --lineto
        if i.command == 'L' then self:lineTo(i[1], i[2], i.command) end
        if i.command == 'i' then self:lineToRelative(i[1], i[2], i.command) end
        --h line
        if i.command == 'h' then self:lineToRelative(i[1], 0, i.command) end
        if i.command == 'H' then self:lineTo(i[1], self.pos.y, i.command) end -- y param
        -- v line
        if i.command == 'v' then self:lineToRelative(0, i[1], i.command) end
        if i.command == 'V' then self:lineTo(self.pos.x, i[1], i.command) end -- x param
        -- Cubic curveto C (c)
        if i.command == 'c' then self:curveToRelative(i[1], i[2], i[3], i[4], i[5], i[6]) end
        if i.command == 'C' then self:curveTo(i[1], i[2], i[3], i[4], i[5], i[6]) end
        -- Cubic shorthand curveto S (s)
        if i.command == 's' then self:smoothCurveToRelative(0, i[1], i.command) end
        if i.command == 'S' then self:smoothCurveTo(self.pos.x, i[1], i.command) end
    end)
end

-- convert svg to points at first
-- create triangles for each quadratic curve

function Em:curveTo(x1, y1, x2, y2, x3, y3)
    local x, y = 0
    _.push(self.data_, { self.pos.x, self.pos.y, 0 })
    x = x1
    y = y1
    _.push(self.data_, { x, y, 0 })
    x = x2
    y = y2
    _.push(self.data_, { x, y, 0 })
    x = x3
    y = y3
    _.push(self.data_, { x, y, 0 })
    self.pos.x = x3
    self.pos.y = y3
end

function Em:curveToRelative(x1, y1, x2, y2, x3, y3)
    local x, y = 0
    -- end point 1
    _.push(self.data_, { self.pos.x, self.pos.y, 0 })

    -- control point 1
    x = self.pos.x + x1
    y = self.pos.y + y1
    _.push(self.data_, { x, y, 0 })

    -- control point 2
    x = self.pos.x + x2
    y = self.pos.y + y2
    _.push(self.data_, { x, y, 0 })

    -- end point 2
    x = self.pos.x + x3
    y = self.pos.y + y3
    _.push(self.data_, { x, y, 0 })

    self.pos.x = x3
    self.pos.y = y3
end

function Em:smoothToRelative(x1, y1, x2, y2, x3, y3, x4, y4)
    local x, y = 0
    -- end point 1
    _.push(self.data_, { self.pos.x, self.pos.y, 0 })

    -- control point 1
    x = self.pos.x + x1
    y = self.pos.y + y1
    _.push(self.data_, { x, y, 0 })

    -- control point 2
    x = self.pos.x + x1
    y = self.pos.y + y1
    _.push(self.data_, { x, y, 0 })

    -- end point 2
    x = self.pos.x + x3
    y = self.pos.y + y3
    _.push(self.data_, { x, y, 0 })

    self.pos.x = x2
    self.pos.y = y2
end


function Em:moveTo(x, y)
    if (self.pos.started == nil) then
        self.pos.started = true
        self.startPos.x = x;
        self.startPos.y = y;
    end
    self.pos.x = x;
    self.pos.y = y;
    self:lineTo(x, y)
end

function Em:lineTo(x, y, r)
    --print(r,x,y)
    --print('\npoint',r,x,y)
    _.push(self.data_, { x, y, 0 })
    self.pos.x = x;
    self.pos.y = y;
end

function Em:lineToRelative(x, y, r)
    -- print('\nrel',r,x,y)
    --print(r,x,y)
    self.pos.x = self.pos.x + x
    self.pos.y = self.pos.y + y
    _.push(self.data_, { self.pos.x, self.pos.y, 0 })
end



function Em:smoothCurveToRelative(x1, y1, x2, y2, x3, y3, x4, y4)
end

function Em:smoothCurveTo(x1, y1, x2, y2, x3, y3, x4, y4)
end


function Em:closePath()
    --close path
    self:lineTo(self.startPos.x, self.startPos.y)
    print('data before normalize:', inspect(self.data_))
    self.data_ = _.flatten(self.data_)
    local maxX = 800
    local maxY = 800
    local min = 0
    -- inverse to follow top left origin
    for k, v in pairs(self.data_) do
        local n = v --between 0 and 1
        if (k % 3 == 1) then
            n = (v - min) / (maxX - min)
            n = ((n * 2) - 1)
            -- so zero x should be -1
        end
        if (k % 3 == 2) then
            n = (v - min) / (maxY - min)
            n = -((n * 2) - 1)
            -- so zero y should be -1
        end

        self.data_[k] = n
        --print(k,self.data_[k])
    end
    print('data>>>')
end



function Em:destroy()
    print('emma:destroy');
end

return Em
