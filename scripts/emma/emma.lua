
Em = Class()

function Em:init()
    self.vbo = {};
    self.vao = {};
    self.inputs = {};
    self.shaders = {};
    self.meshes = {};
    self.meshes.hull = {}
    self.dataSets = {};
    --setup shader
    local shader = self:addShader('default');
    self.shaders.default = shader;

    local a= "M47.8,110.8l25.3-40.4c0,0-2.2,60,52,37.8 s-7.1,69.3 -7.1,69.3 l-65.3-2.7L47.8,110.8z"
    local str = "M55.7,131.1c0.4,24.4,16,34.4,34,34.4c12.9,0,20.7-2.3,27.4-5.1l3.1,12.9c-6.4,2.9-17.2,6.2-33,6.2c-30.5,0-48.7-20.1-48.7-50s17.6-53.4,46.5-53.4c32.4,0,41,28.5,41,46.7c0,3.7-0.4,6.6-0.6,8.4H55.7z"
    str = "M55.7,131.1c0.4,24.4,16,34.4,34,34.4c12.9,0,20.7-2.3,27.4-5.1l3.1,12.9c-6.4,2.9-17.2,6.2-33,6.2c-30.5,0-48.7-20.1-48.7-50s17.6-53.4,46.5-53.4c32.4,0,41,28.5,41,46.7c0,3.7-0.4,6.6-0.6,8.4H55.7zM108.5,118.2c0.2-11.5-4.7-29.3-25-29.3c-18.2,0-26.2,16.8-27.6,29.3H108.5z"  -- M108.5,118.2c0.2-11.5-4.7-29.3-25-29.3c-18.2,0-26.2,16.8-27.6,29.3H108.5z
    str = "M113.8,148.7c-4.5,1.6-13.5,4.3-24.1,4.3c-11.9,0-21.6-3-29.3-10.3c-6.7-6.5-10.9-17-10.9-29.2c0.1-23.4,16.2-40.4,42.4-40.4c9.1,0,16.2,2,19.5,3.6l-2.4,8.2c-4.2-1.9-9.4-3.4-17.3-3.4c-19.1,0-31.5,11.9-31.5,31.5c0,19.9,12,31.6,30.2,31.6c6.6,0,11.2-0.9,13.5-2.1v-23.4H88v-8.1h25.8V148.7z"
    str = "M48.6,107.3C49.3,151,77.2,169,109.5,169c23.1,0,37.1-4,49.2-9.2l5.5,23.1c-11.4,5.1-30.8,11-59.1,11c-54.7,0-87.4-36-87.4-89.6S49.3,8.6,101.1,8.6c58,0,73.4,51,73.4,83.7c0,6.6-0.7,11.7-1.1,15.1H48.6z M143.3,84.2c0.4-20.6-8.4-52.5-44.8-52.5c-32.7,0-47,30.1-49.6,52.5H143.3z"
    self.str = "M105.1,194c-54.7,0-87.4-36-87.4-89.6l30.9,2.9C49.3,151,77.2,169,109.5,169L105.1,194z"

    -- make vao
    local svg = SVG:new();
    local data = svg:extract(self.str);
    --data.curve
    --data.hull
    self:attachData("position",data,shader);

    -- create material

    -- create geometry
    self.geometry = {}
    self.geometry.mv = mat4();
    self.geometry.pr = mat4:CreateProjection(150, System.screen().height / System.screen().width, 0, 1000);
end

function Em:addShader(name)
    local p = shader(name)
    _.push(self.shaders, p);
    return p
end


function Em:attachData(name, dataSet, shader)
    local shaderLoc;
    if(self.dataSets[name] == nil) then
        self.dataSets[name] = {}
    end
    data = self.dataSets[name]
    data.count = dataSet.count
    data.vertices = array.new(dataSet.vertices)
    print("dataset",#_.keys(self.dataSets))

    data.vao = gl.GenVertexArrays()
    gl.BindVertexArray(data.vao)

    data.vbo = gl.GenBuffers()

    gl.BindBuffer(gl.ARRAY_BUFFER, data.vbo)
    data.cRef = gl.CopyData(data.vertices, array.len(data.vertices));
    gl.BufferData(gl.ARRAY_BUFFER, 4*3*array.len(data.vertices), data.cRef, gl.DYNAMIC_DRAW )

    data.shaderLoc = shader:setAttribute(name)
    gl.EnableVertexAttribArray(data.shaderLoc)
    gl.VertexAttribPointer(0,3,gl.FLOAT,gl.FALSE,0,0)

    gl.BindVertexArray(0);
end

function Em:getData(name)
    return self.dataSets[name];
end
 

function Em:update(delta)
    local a = app.system.runTime / 100000
    s = (math.sin(a) + 1) / 2
    local m = matrix:get('mv');
    local p = matrix:get('proj');
    m:assign(self.geometry.mv)
    --m:multiply(1.5)
    --m:translate(0.7, -0.5, 0) -- (100*s)
    -- m:translate(0,0, -100)-- (100*s)) ---
    p:assign(self.geometry.pr)
    p:multiply(m)
end
 
function Em:draw()
    local shader, m

    shader = self.shaders.default;
    shader:use()
    gl.PointSize(5)

    -- go through data sets and bind
    local data = self:getData('position');
    gl.BindVertexArray(data.vao);

    -- set geometry
    m = matrix:get('mv');
    m:translate(0, 0, 0)
    gl.UniformMatrix4fv(shader.inputs.mvpm, 1, 0, matrix:get('mv'));

    -- set color
    local uniformColorLoc = gl.GetUniformLocation(shader.program, "color");
    local color = vec3(1.0,0.0,1.0);
    gl.Uniform3fv(uniformColorLoc,color);

    -- draw
    gl.DrawArrays(gl.TRIANGLES, 0, data.count);
    gl.BindVertexArray(0);


    _.each(_.keys(self.dataSets), function(data) end)
        

end



function Em:destroy()
end

return Em




