#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 velocity;
layout (location = 2) in vec4 color;
layout (location = 3) in vec2 size;
layout (location = 4) in float timeToLive;

out vec3 positionMod;
out vec3 velocityMod;
out vec4 colorMod;
out vec2 sizeMod;
out float timeToLiveMod;

uniform float time;
uniform float dt;

uint seed = uint(time * 1000.0) + uint(gl_VertexID);
uint randhash( ) // entre  0 et UINT_MAX
{
    uint i=((seed++)^12345391u)*2654435769u;
    i ^= (i<<6u)^(i>>26u); i *= 2654435769u; i += (i<<5u)^(i>>12u);
    return i;
}
float random() // entre  0 et 1
{
    const float UINT_MAX = 4294967295.0;
    return float(randhash()) / UINT_MAX;
}

const float PI = 3.14159265359f;
vec3 randomInCircle(in float radius, in float height)
{
    float r = radius * sqrt(random());
    float theta = random() * 2 * PI;
    return vec3(r * cos(theta), height, r * sin(theta));
}


const float MAX_TIME_TO_LIVE = 2.0f;
const float INITIAL_RADIUS = 0.2f;
const float INITIAL_HEIGHT = 0.0f;
const float FINAL_RADIUS = 0.5f;
const float FINAL_HEIGHT = 5.0f;

const float INITIAL_SPEED_MIN = 0.5f;
const float INITIAL_SPEED_MAX = 0.6f;

const float INITIAL_TIME_TO_LIVE_RATIO = 0.85f;

const float INITIAL_ALPHA = 0.0f;
const float ALPHA = 0.1f;
const vec3 YELLOW_COLOR = vec3(1.0f, 0.9f, 0.0f);
const vec3 ORANGE_COLOR = vec3(1.0f, 0.4f, 0.2f);
const vec3 DARK_RED_COLOR = vec3(0.1, 0.0, 0.0);

const vec3 ACCELERATION = vec3(0.0f, 0.1f, 0.0f);

void main()
{
    // TODO
    float normalizedLifeTime = 1.0 - (timeToLive/MAX_TIME_TO_LIVE);
    if(timeToLive <= 0.0f)
    {
        positionMod = randomInCircle(INITIAL_RADIUS, INITIAL_HEIGHT);

        vec3 velocityDirection = randomInCircle(FINAL_RADIUS, FINAL_HEIGHT);

        float speed = INITIAL_SPEED_MIN + random() * (INITIAL_SPEED_MAX - INITIAL_SPEED_MIN);
        velocityMod = normalize(velocityDirection) * speed;

        timeToLiveMod = 1.7f * random() * 0.3f;
    }
    else
    {
        positionMod = position + velocity * dt;
        velocityMod = velocity + ACCELERATION * dt;

        timeToLiveMod = timeToLive - dt;
    }

    if (normalizedLifeTime <= 0.25)
    {
        colorMod = vec4(YELLOW_COLOR, smoothstep(0.0f, 2.0f, normalizedLifeTime) * (1.0 - smoothstep(0.0f, 2.0f, normalizedLifeTime)));
    }
    else if (normalizedLifeTime <= 0.5)
    {
        colorMod =  vec4(ORANGE_COLOR, 1.0f);
    }
    else if (normalizedLifeTime <= 1.0)
    {
        colorMod = vec4(DARK_RED_COLOR, smoothstep(0.5f, 1.0f, normalizedLifeTime) * (1.0 - smoothstep(0.5f, 1.0f, normalizedLifeTime)));
    }

    float sizeFactor = 1.0 + 0.5 * normalizedLifeTime;
    sizeMod = vec2(size.x * sizeFactor, size.y);

    float alphaMod = smoothstep(0.0f, 2.0f, normalizedLifeTime) * (1.0 - smoothstep(0.0f, 2.0f, normalizedLifeTime));
    colorMod.a = alphaMod;
}
