#version 400 core

layout(quads) in;

// in Attribs {
//     vec4 couleur;
// } AttribsIn[];


out ATTRIB_TES_OUT
{
    float height;
    vec2 texCoords;
    vec4 patchDistance;
} attribOut;

uniform mat4 mvp;

uniform sampler2D heighmapSampler;

vec4 interpole( vec4 v0, vec4 v1, vec4 v2, vec4 v3 )
{
    // mix( x, y, f ) = x * (1-f) + y * f.

    // taken from the notes
    // TODO
    vec4 v0_1 = mix(v0, v1, gl_TessCoord.x);
    vec4 v3_2 = mix(v3, v2, gl_TessCoord.x);
    return mix(v0_1, v3_2, gl_TessCoord.y);
}

const float PLANE_SIZE = 256.0f;

void main()
{
	// TODO
    vec4 p0 = gl_in[0].gl_Position;
    vec4 p1 = gl_in[1].gl_Position;
    vec4 p2 = gl_in[2].gl_Position;
    vec4 p3 = gl_in[3].gl_Position;
    vec4 interpolation = interpole(p0, p1, p2, p3);

    vec2 texcoord = (vec2(interpolation.x, interpolation.z) + vec2(PLANE_SIZE / 2.0)) / (PLANE_SIZE * 4);

    float height = texture(heighmapSampler, texcoord).r;
    float heightAdjusted = height * 64.0 - 32.0;
    interpolation.y += heightAdjusted;

    gl_Position = mvp * interpolation;
    attribOut.texCoords = texcoord;
    attribOut.height = heightAdjusted;
    attribOut.patchDistance = vec4(gl_TessCoord.x, 1 - gl_TessCoord.x, gl_TessCoord.y, 1-gl_TessCoord.y);
}
