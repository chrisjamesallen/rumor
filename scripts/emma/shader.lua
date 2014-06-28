
--Shader Class Object

--Constructor
function shader(type)
    local program = Shader.programs[type];
    ---if(program){
     -- return program
    --}
    program = Shader:new()
    program:create("default", VERTSTR, FRAGSTR);
    return program;
end

--Class

Shader= Class()
Shader.programs = {}

function Shader:init()
    local b = self.__index
    b.__gc = self.destroy
    setmetatable(self, b)
    self.inputs = {}
end

function Shader:create(name, vert, frag)
    -- create and compile shader
    local vsh = gl.CreateShader(gl.VERTEX_SHADER)
    local fsh = gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(vsh, vert)
    gl.ShaderSource(fsh, frag)
    gl.CompileShader(vsh)
    gl.CompileShader(fsh)
    self.program = gl.CreateProgram()
    gl.AttachShader(self.program, vsh)
    gl.AttachShader(self.program, fsh)
    gl.LinkProgram(self.program)
    gl.DeleteShader(vsh)
    gl.DeleteShader(fsh)
    --todo add validation
    Shader.programs[name] = self;
end

function Shader:setAttribute(name)
    self.inputs[name] = gl.GetAttribLocation(self.program, name)
    return self.inputs[name];
end

function Shader:setUniform(name)
    self.inputs[name] = gl.GetUniformLocation(self.program, name)
    return self.inputs[name];
end

function Shader:getAttribute(name)
    return gl.GetAttribLocation(self.program, name)
end

function Shader:getUniform(name)
    return gl.GetUniformLocation(self.program, name)
end

function Shader:use()
    gl.UseProgram(self.program)
end

function Shader:update()
    
end

function Shader:draw()
    
end

function Shader:destroy()
    --print("destroy:shader");
    gl.DeleteProgram(self.program)
end

 

VERTSTR = [[
#version 410 core


in vec4 position;
in vec4 sexy;
uniform mat4 modelViewProjectionMatrix;
void main()
{
gl_Position =  modelViewProjectionMatrix * position;
}

]]

FRAGSTR = [[
#version 410 core

out vec4 outFragColor;

void main()
{
    outFragColor = vec4(1.0,0.0,0.0,1.0);
}

]]



