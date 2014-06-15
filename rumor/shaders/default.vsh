#version 410 core


in vec4 position;
uniform mat4 modelViewProjectionMatrix;

void main()
{
    gl_Position =  position;
}
