--[[ Oh yeah app baby --]]
Em = Class()

function Em:init()
    self.vbo = {};
    self.vao = {};
    self.inputs = {}; 
    self.programs = {};

       --setup shader
    self.program = shader('default');
    self.program:setAttribute('position');
    self.program:setUniform('modelViewProjectionMatrix');
    self.program.inputs.mvpm = self.program:getUniform('modelViewProjectionMatrix')  

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

    -- close vao
    gl.BindVertexArray(0)

    -- create geometry
    self.geometry = {}
    self.geometry.mv = mat4();
    print(SCREEN.height/SCREEN.width)
    self.geometry.pr = mat4:CreateProjection(150, SCREEN.height/SCREEN.width, 0,1000);
end

function Em:update(delta)
    local a = RUNTIME / 100000
    s = (math.sin(a) + 1)  /2
    local m = matrix:get('mv');
    local p = matrix:get('proj');
    m:assign(self.geometry.mv) 
    m:translate(0,0, -(100*s) )--
    p:assign(self.geometry.pr)
    p:multiply(m)
end
 
function Em:draw()
    -- use correct shader
    self.program:use();

    -- bind vao
    gl.BindVertexArray(self.vao[1])
    gl.UniformMatrix4fv(self.program.inputs.mvpm, 1, 0, matrix:get('proj'));  
 
    -- draw data
    gl.DrawArrays(gl.TRIANGLE_STRIP,0,4)

end

function Em:destroy()
    print('emma:destroy');
end
 
