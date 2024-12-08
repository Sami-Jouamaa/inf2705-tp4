#version 400 core

layout(quads) in;

// in Attribs {
//     vec4 couleur;
// } AttribsIn[];

in vec2 tessTexCoords[];
out vec2 fTexCoords;


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
    vec4 v0_1 = mix(v0, v1, gl_TessCoord.x);
    vec4 v3_2 = mix(v3, v2, gl_TessCoord.x);
    return mix(v0_1, v3_2, gl_TessCoord.y);
}

vec2 interpoleTexCoords(vec2 v0, vec2 v1, vec2 v2, vec2 v3)
{
    vec2 v0_1 = mix(v0, v1, gl_TessCoord.x);
    vec2 v3_2 = mix(v3, v2, gl_TessCoord.x); 
    return mix(v0_1, v3_2, gl_TessCoord.y);  
}

void main()
{
	// TODO
    vec4 p0 = gl_in[0].gl_Position;
    vec4 p1 = gl_in[1].gl_Position;
    vec4 p2 = gl_in[2].gl_Position;
    vec4 p3 = gl_in[3].gl_Position;
    vec4 interpolation = interpole(p0, p1, p2, p3);

    vec2 tc0 = tessTexCoords[0];
    vec2 tc1 = tessTexCoords[1];
    vec2 tc2 = tessTexCoords[2];
    vec2 tc3 = tessTexCoords[3];
    vec2 texCoord = interpoleTexCoords(tc0, tc1, tc2, tc3);

    float height = texture(heighmapSampler, texCoord).x;
    float heightAdjusted = height * 64.0 - 32.0;
    interpolation.y += heightAdjusted;

    gl_Position = mvp * interpolation;
    attribOut.texCoords = texCoord;
    attribOut.height = heightAdjusted;
    attribOut.patchDistance = vec4(gl_TessCoord.x, 1 - gl_TessCoord.x, gl_TessCoord.y, 1-gl_TessCoord.y);
}
