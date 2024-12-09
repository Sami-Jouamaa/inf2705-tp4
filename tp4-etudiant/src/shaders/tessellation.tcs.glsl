#version 400 core

layout(vertices = 4) out;

uniform mat4 modelView;


const float MIN_TESS = 4;
const float MAX_TESS = 64;

const float MIN_DIST = 30.0f;
const float MAX_DIST = 100.0f;

float calculateTessFactor(vec3 edgeDistance) {
    float distance = length(edgeDistance);
    return mix(MAX_TESS, MIN_TESS, clamp((distance - MIN_DIST)/(MAX_DIST - MIN_DIST), 0.0, 1.0));
}

void main()
{
	// TODO
    // In charge of LOD.
    vec3 edgeCenter0 = (modelView * ((gl_in[0].gl_Position + gl_in[1].gl_Position) / 2.0)).xyz; // Edge 0-1
    vec3 edgeCenter1 = (modelView * ((gl_in[1].gl_Position + gl_in[2].gl_Position) / 2.0)).xyz; // Edge 1-2
    vec3 edgeCenter2 = (modelView * ((gl_in[2].gl_Position + gl_in[3].gl_Position) / 2.0)).xyz; // Edge 2-3
    vec3 edgeCenter3 = (modelView * ((gl_in[3].gl_Position + gl_in[0].gl_Position) / 2.0)).xyz; // Edge 3-0
    
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;

    if(gl_InvocationID == 0)
    {
        gl_TessLevelOuter[0] = calculateTessFactor(edgeCenter0);
        gl_TessLevelOuter[1] = calculateTessFactor(edgeCenter1);
        gl_TessLevelOuter[2] = calculateTessFactor(edgeCenter2);
        gl_TessLevelOuter[3] = calculateTessFactor(edgeCenter3);

        gl_TessLevelInner[0] = max(gl_TessLevelOuter[0], gl_TessLevelOuter[2]);
        gl_TessLevelInner[1] = max(gl_TessLevelOuter[1], gl_TessLevelOuter[3]);
    }
}
