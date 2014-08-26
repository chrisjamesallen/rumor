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
    svg:convertSvg(data);
    data = array.new(svg.data_, 500);
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
    --m:multiply(3.0)
    --m:translate(-0.2, 0.2, 0) --- (100*s)
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
    gl.DrawArrays(gl.POINTS, 0, 80)
end



function Em:destroy()
end

return Em
