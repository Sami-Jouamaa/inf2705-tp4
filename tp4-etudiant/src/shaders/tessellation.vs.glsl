#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 texCoords;

out vec2 tcTexCoords;

void main()
{
    tcTexCoords = texCoords;
    gl_Position = vec4(position, 1);
}
