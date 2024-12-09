#version 330 core

in ATTRIB_GS_OUT
{
    float height;
    vec2 texCoords;
    vec4 patchDistance;
    vec3 barycentricCoords;
} attribIn;

uniform sampler2D groundSampler;
uniform sampler2D sandSampler;
uniform sampler2D snowSampler;
uniform bool viewWireframe;

out vec4 FragColor;

float edgeFactor(vec3 barycentricCoords, float width)
{
    vec3 d = fwidth(barycentricCoords);
    vec3 f = step(d * width, barycentricCoords);
    return 1.0 - min(min(f.x, f.y), f.z);
}


const vec3 WIREFRAME_COLOR = vec3(0.5f);
const vec3 PATCH_EDGE_COLOR = vec3(1.0f, 0.0f, 0.0f);

const float WIREFRAME_WIDTH = 0.5f;
const float PATCH_EDGE_WIDTH = 0.5f;

void main()
{
	// TODO
    float edgeFactorUse = edgeFactor(attribIn.barycentricCoords, PATCH_EDGE_WIDTH);
    FragColor = vec4(0, 0, 0, 1);
    float factor;
    vec4 textureMix;

    if (attribIn.height < -10.0)
    {
        textureMix = texture(sandSampler, attribIn.texCoords);
    }
    else if (attribIn.height < -8.0)
    {
        factor = smoothstep(-10.0, -8.0, attribIn.height);
        vec4 sand = texture(sandSampler, attribIn.texCoords);
        vec4 grass = texture(groundSampler, attribIn.texCoords);
        textureMix = mix(sand, grass, factor);
    } else if (attribIn.height < 6.0) {
        textureMix = texture(groundSampler, attribIn.texCoords);
    }
    else if (attribIn.height < 10.0) 
    {
        factor = smoothstep(6.0, 10.0, attribIn.height);
        vec4 grass = texture(groundSampler, attribIn.texCoords);
        vec4 snow = texture(snowSampler, attribIn.texCoords);
        textureMix = mix(grass, snow, factor);
    }
    else
    {
        textureMix = texture(snowSampler, attribIn.texCoords);
    }
    if (viewWireframe) {
        vec3 finalColor = mix(textureMix.rgb, PATCH_EDGE_COLOR, edgeFactorUse);
        FragColor = vec4(vec3(finalColor), 1.0);
    } else {
        FragColor = vec4(textureMix.xyz, 1.0);
    }

}
