#version 330 core

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;


in ATTRIB_VS_OUT
{
    vec4 color;
    vec2 size;
} attribIn[];

out ATTRIB_GS_OUT
{
    vec4 color;
    vec2 texCoords;
} attribOut;

uniform mat4 projection;

void main()
{
    // TODO
    vec3 position = gl_in[0].gl_Position.xyz;

    vec3 halfwayPoint = vec3(attribIn[0].size * 0.5, attribIn[0].size.x * 0.5, 0.0);

    vec3 corners[4];
    corners[0] = position + vec3(-halfwayPoint.x, -halfwayPoint.y, 0.0); // (0,0) kinda
    corners[1] = position + vec3(-halfwayPoint.x, halfwayPoint.y, 0.0); // (0, 1)
    corners[2] = position + vec3(halfwayPoint.x, -halfwayPoint.y, 0.0); // (1,0)
    corners[3] = position + vec3(halfwayPoint.x, halfwayPoint.y, 0.0); // (1,1)

    for (int i = 0; i < 4; i++)
    {
        gl_Position = projection * vec4(corners[i], 1.0);
        attribOut.color = attribIn[i].color;
        attribOut.texCoords = attribIn[i].texCoords;
        EmitVertex();
    }
    EndPrimitive();
}
