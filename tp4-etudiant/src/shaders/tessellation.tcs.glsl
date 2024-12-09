#version 400 core

layout(vertices = 4) out;

uniform mat4 modelView;


const float MIN_TESS = 4;
const float MAX_TESS = 64;

const float MIN_DIST = 30.0f;
const float MAX_DIST = 100.0f;

void main()
{
	// TODO
    // In charge of LOD.
    vec3 patchCenterDistance = (gl_in[0].gl_Position.xyz + gl_in[1].gl_Position.xyz + gl_in[2].gl_Position.xyz + gl_in[3].gl_Position.xyz)/4.0;
    vec3 vectorDistance = gl_in[gl_InvocationID].gl_Position.xyz - patchCenterDistance;

    float distance = sqrt(pow(vectorDistance.x, 2) + pow(vectorDistance.y, 2) + pow(vectorDistance.z, 2));
    float tessFactor = mix(MIN_TESS, MAX_TESS, clamp((distance - MIN_DIST)/(MAX_DIST - MIN_DIST), 0.0, 1.0));
    
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;

    if(gl_InvocationID == 0)
    {
        gl_TessLevelOuter[0] = distance; // Temporarily output raw distance
        gl_TessLevelOuter[1] = distance;
        gl_TessLevelOuter[2] = distance;
        gl_TessLevelOuter[3] = distance;
        gl_TessLevelInner[0] = distance;
        gl_TessLevelInner[1] = distance;
    }

    // gl_in[0].gl_Position; // (0,0)
    // gl_in[1].gl_Position; // (1,0)
    // gl_in[2].gl_Position; // (1,1)
    // gl_in[3].gl_Position; // (0,1)

}
