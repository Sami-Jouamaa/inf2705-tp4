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
    return min(min(f.x, f.y), f.z);
}

float edgeFactor(vec4 barycentricCoords, float width)
{
    vec4 d = fwidth(barycentricCoords);
    vec4 f = step(d * width, barycentricCoords);
    return min(min(min(f.x, f.y), f.z), f.w);
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

    if (viewWireframe) 
    {
        FragColor = vec4(WIREFRAME_COLOR, 1.0);
    }
    else 
    {
        float factor;
        vec4 textureMix;

        if (attribIn.height < 0.3)
        {
            textureMix = texture(sandSampler, attribIn.texCoords);
        }
        else if (attribIn.height < 0.35)
        {
            factor = smoothstep(0.3, 0.35, attribIn.height);
            vec4 sand = texture(sandSampler, attribIn.texCoords);
            vec4 grass = texture(groundSampler, attribIn.texCoords);
            textureMix = mix(sand, grass, factor);
        }
        else if (attribIn.height < 0.65) 
        {
            factor = smoothstep(0.6, 0.65, attribIn.height);
            vec4 grass = texture(groundSampler, attribIn.texCoords);
            vec4 snow = texture(snowSampler, attribIn.texCoords);
            textureMix = mix(grass, snow, factor);
        }
        else
        {
            textureMix = texture(snowSampler, attribIn.texCoords);
            factor = 1.0;
        }

        vec3 finalColor = mix(textureMix.rgb, PATCH_EDGE_COLOR, edgeFactorUse);
        FragColor = vec4(finalColor, 1.0);
    }
}
