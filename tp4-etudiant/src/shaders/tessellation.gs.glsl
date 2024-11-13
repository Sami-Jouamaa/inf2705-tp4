#version 330 core

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;


in ATTRIB_TES_OUT
{
    float height;
    vec2 texCoords;
    vec4 patchDistance;
} attribIn[];

out ATTRIB_GS_OUT
{
    float height;
    vec2 texCoords;
    vec4 patchDistance;
    vec3 barycentricCoords;
} attribOut;

void main()
{
    // TODO
    // Which attribIn to take ?
    attribOut.height = attribIn[0].height;
    attribOut.texCoords = attribIn[0].texCoords;
    attribOut.patchDistance = attribIn[0].patchDistance;
    // attribOut.barycentricCoords
}
