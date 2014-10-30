
--Shader Class Object
--Class
Shader = Class()
Shader.programs = {}
 
--Constructor
function shader(type, vert, frag)
    local program = Shader.programs[type];
    if(program ~= nil) then
      print('should return early!\n')
      do return program end
    end
    print('create shader');
    program = Shader:new()
    program:create(type or "default", vert or VERTSTR, frag or FRAGSTR);
    _.push(Shader.programs, program);
    return program;
end

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
    local l =  gl.GetAttribLocation(self.program, name)
    self.inputs[name] = l
    if(l == -1) then
         print("gl error: gl attach attribute name", name, l)
    end
    return l;
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
   -- print("destroy:shader\n");
    gl.DeleteProgram(self.program)
end

 

VERTSTR = [[
#version 410 core


in vec3 position;
uniform vec3 color;
uniform mat4 modelViewProjectionMatrix;
void main()
{
    gl_Position =  modelViewProjectionMatrix * vec4(position,1.0);
}

]]

FRAGSTR = [[
#version 410 core
out vec4 outFragColor;
void main()
{  
    outFragColor = vec4(1.0, 1.0, 1.0, 1.0);
}

]]


GLSL_V_CURVE = [[
#version 410 core


in vec3 position;
in vec3 texCoord;
uniform vec3 color;
uniform mat4 modelViewProjectionMatrix;
out vec3 vBezierCoord;
out float foo;
void main()
{
gl_Position =  modelViewProjectionMatrix * vec4(position,1.0);
vBezierCoord = texCoord;
foo = texCoord[2];
}

]]

GLSL_F_CURVE = [[
#version 410 core

out vec4 outFragColor;
in vec3 vBezierCoord;
in float foo;
uniform vec3 color;
void main()
{
float d = (vBezierCoord.x * vBezierCoord.x) - vBezierCoord.y;
highp float c = vBezierCoord.z;
if(d< 0.0 && c == 0.0) {
outFragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
else if(d> 0.0 && c == 1.0) {
outFragColor = vec4(1.0, 0.0, 1.0, 1.0);
} else{
discard;
}

}

]]



return Shader;





