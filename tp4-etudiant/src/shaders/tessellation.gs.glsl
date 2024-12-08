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

    vec3 p0 = gl_in[0].gl_Position.xyz;
    vec3 p1 = gl_in[1].gl_Position.xyz;
    vec3 p2 = gl_in[2].gl_Position.xyz;
    float triangleArea = cross(p1 - p0, p2 - p0).z;

    for (int i = 0; i < 3; i++) 
    {
        vec3 v0 = p0 - p1;
        vec3 v1 = p2 - p1;
        vec3 v2 = gl_in[i].gl_Position.xyz - p1;

        float u = cross(v1, v2).z/triangleArea;
        float v = cross(v2, v0).z/triangleArea;
        float w = 1.0 - u - v;

        attribOut.barycentricCoords = vec3(u, v, w);
        attribOut.texCoords = attribIn[i].texCoords;
        attribOut.height = attribIn[i].height;
        attribOut.patchDistance = attribIn[i].patchDistance;

        gl_Position = gl_in[i].gl_Position;
        EmitVertex();
    }

    EndPrimitive();
}
