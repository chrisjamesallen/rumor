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
    local svg = SVG:new();
    local a= "M47.8,110.8l25.3-40.4c0,0-2.2,60,52,37.8 s-7.1,69.3 -7.1,69.3 l-65.3-2.7L47.8,110.8z"
    local str = "M55.7,131.1c0.4,24.4,16,34.4,34,34.4c12.9,0,20.7-2.3,27.4-5.1l3.1,12.9c-6.4,2.9-17.2,6.2-33,6.2c-30.5,0-48.7-20.1-48.7-50s17.6-53.4,46.5-53.4c32.4,0,41,28.5,41,46.7c0,3.7-0.4,6.6-0.6,8.4H55.7z"
    str = "M55.7,131.1c0.4,24.4,16,34.4,34,34.4c12.9,0,20.7-2.3,27.4-5.1l3.1,12.9c-6.4,2.9-17.2,6.2-33,6.2c-30.5,0-48.7-20.1-48.7-50s17.6-53.4,46.5-53.4c32.4,0,41,28.5,41,46.7c0,3.7-0.4,6.6-0.6,8.4H55.7zM108.5,118.2c0.2-11.5-4.7-29.3-25-29.3c-18.2,0-26.2,16.8-27.6,29.3H108.5z"  -- M108.5,118.2c0.2-11.5-4.7-29.3-25-29.3c-18.2,0-26.2,16.8-27.6,29.3H108.5z
    str = "M113.8,148.7c-4.5,1.6-13.5,4.3-24.1,4.3c-11.9,0-21.6-3-29.3-10.3c-6.7-6.5-10.9-17-10.9-29.2c0.1-23.4,16.2-40.4,42.4-40.4c9.1,0,16.2,2,19.5,3.6l-2.4,8.2c-4.2-1.9-9.4-3.4-17.3-3.4c-19.1,0-31.5,11.9-31.5,31.5c0,19.9,12,31.6,30.2,31.6c6.6,0,11.2-0.9,13.5-2.1v-23.4H88v-8.1h25.8V148.7z"
    local points = svg:extractToPoints(str);
    self.vertsCount = svg.vertices
    local data = array.new(points, svg.points);
    self.vertsRef = gl.CopyData(data, array.len(data));
    gl.BufferData(gl.ARRAY_BUFFER, 4 * 3 * array.len(data), self.vertsRef, gl.DYNAMIC_DRAW);
    -- point data to attrib input
    local p = self.programs[1];
    gl.EnableVertexAttribArray(p.inputs.position)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, 0)
    -- close vao
    gl.BindVertexArray(0)
    --print("verts count",svg.vertices, inspect(points), array.len(data))
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
    --m:multiply(1.5)
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
    gl.DrawArrays(gl.TRIANGLES, 0, self.vertsCount)--)
end



function Em:destroy()
end

return Em
