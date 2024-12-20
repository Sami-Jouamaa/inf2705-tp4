#include "scene_particles.h"

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "imgui/imgui.h"

#include "utils.h"
#include "shader_object.h"

#include <iostream>



static const unsigned int MAX_N_PARTICULES = 10000;
static Particle particles[MAX_N_PARTICULES] = { {{0,0,0},{0,0,0},{0,0,0,0}, {0,0},0} };

void initializeParticles() {
    for (unsigned int i = 0; i < MAX_N_PARTICULES; ++i) {
        particles[i].position = glm::vec3(0.0f);
        particles[i].velocity = glm::vec3(
            (float(rand()) / RAND_MAX - 0.5f) * 2.0f,
            (float(rand()) / RAND_MAX) * 2.0f,
            (float(rand()) / RAND_MAX - 0.5f) * 2.0f
        );
        particles[i].color = glm::vec4(1.0f, 0.5f, 0.0f, 1.0f);
        particles[i].size = glm::vec2(1.0f);               
        particles[i].timeToLive = float(rand()) / RAND_MAX * 5.0f;
    }
}

SceneParticles::SceneParticles(bool& isMouseMotionEnabled)
: Scene()
, m_isMouseMotionEnabled(isMouseMotionEnabled)
, m_cameraOrientation(0)
, m_oldTime(0)
, m_cumulativeTime(0.0f)
, m_tfo(0)
, m_vao(0)
, m_vbo{0, 0}
, m_nParticles(1)
, m_nMaxParticles(1000)
, m_timeLocationTransformFeedback(-1)
, m_dtLocationTransformFeedback(-1)
, m_modelViewLocationParticle(-1)
, m_projectionLocationParticle(-1)
, m_flameTexture("../textures/flame.png")
, m_menuVisible(true)
{
    initializeShader();
    initializeTexture();

    glEnable(GL_PROGRAM_POINT_SIZE);

    glGenVertexArrays(1, &m_vao);
    glBindVertexArray(m_vao);

    glGenTransformFeedbacks(1, &m_tfo);
    glBindTransformFeedback(GL_TRANSFORM_FEEDBACK, m_tfo);

    glGenBuffers(2, m_vbo);

    initializeParticles();
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo[0]);
    glBufferData(GL_ARRAY_BUFFER, m_nMaxParticles * sizeof(Particle), particles, GL_DYNAMIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, m_vbo[1]);
    glBufferData(GL_ARRAY_BUFFER, m_nMaxParticles * sizeof(Particle), nullptr, GL_DYNAMIC_DRAW);

    glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, m_vbo[1]);


    m_transformFeedbackShaderProgram.use();
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo[0]);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, position));

    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, velocity));

    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, color));

    glEnableVertexAttribArray(3);
    glVertexAttribPointer(3, 2, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, size));

    glEnableVertexAttribArray(4);
    glVertexAttribPointer(4, 1, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, timeToLive));

    m_particuleShaderProgram.use();
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo[1]);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, position));

    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, velocity));

    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, color));

    glEnableVertexAttribArray(3);
    glVertexAttribPointer(3, 2, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, size));

    glEnableVertexAttribArray(4);
    glVertexAttribPointer(4, 1, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, timeToLive));
}

SceneParticles::~SceneParticles()
{
    // TODO
}

void SceneParticles::run(Window& w)
{
    updateInput(w);
    
    drawMenu();
    
    glm::mat4 view = getCameraThirdPerson(2.5);
    glm::mat4 projPersp = getProjectionMatrix(w);
    glm::mat4 modelView = view;

    float time = w.getTick() / 1000.0;
    float dt = time - m_oldTime;
    m_oldTime = time;
    m_cumulativeTime += dt;
    if (dt > 1.0f)
        m_nParticles = 1;

    m_transformFeedbackShaderProgram.use();
    glUniform1f(m_timeLocationTransformFeedback, time);
    glUniform1f(m_dtLocationTransformFeedback, dt);
    glBindVertexArray(m_vao);
    glEnable(GL_RASTERIZER_DISCARD);
    glBindTransformFeedback(GL_TRANSFORM_FEEDBACK, m_tfo);
    glBeginTransformFeedback(GL_POINTS);
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo[0]);
    glDrawArrays(GL_POINTS, 0, m_nParticles);
    glEndTransformFeedback();
    glDisable(GL_RASTERIZER_DISCARD);
    glBindBuffer(GL_TRANSFORM_FEEDBACK_BUFFER, m_vbo[1]);
    
    glBindBuffer(GL_TRANSFORM_FEEDBACK_BUFFER, m_vbo[1]);
    Particle* particleData = new Particle[m_nParticles];
    glGetBufferSubData(GL_TRANSFORM_FEEDBACK_BUFFER, 0, m_nParticles * sizeof(Particle), particleData);

    glBindBuffer(GL_TRANSFORM_FEEDBACK_BUFFER, m_vbo[0]);
    glBufferData(GL_ARRAY_BUFFER, m_nMaxParticles * sizeof(Particle), particleData, GL_DYNAMIC_DRAW);
    delete[] particleData;
    
    m_particuleShaderProgram.use();
    m_flameTexture.use(0);
    
    glUniformMatrix4fv(m_modelViewLocationParticle, 1, GL_FALSE, &modelView[0][0]);
    glUniformMatrix4fv(m_projectionLocationParticle, 1, GL_FALSE, &projPersp[0][0]);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_DEPTH_TEST);
    glDrawArrays(GL_POINTS, 0, m_nParticles);

    // TODO: Draw particles without depth write and with blending

    if (m_cumulativeTime > 1.0f / 60.0f)
    {
        m_cumulativeTime = 0.0f;
        if (++m_nParticles > m_nMaxParticles)
            m_nParticles = m_nMaxParticles;
    }
}

void SceneParticles::updateInput(Window& w)
{
    int x = 0, y = 0;
    if (m_isMouseMotionEnabled)
        w.getMouseMotion(x, y);
    m_cameraOrientation.y -= x * 0.01f;
    m_cameraOrientation.x -= y * 0.01f;
    
    if (w.getKeyHold(Window::Key::W))
        m_cameraOrientation.x -= 0.03;
    if (w.getKeyHold(Window::Key::S))
        m_cameraOrientation.x += 0.03;
    if (w.getKeyHold(Window::Key::A))
        m_cameraOrientation.y -= 0.03;
    if (w.getKeyHold(Window::Key::D))
        m_cameraOrientation.y += 0.03;
}

void SceneParticles::drawMenu()
{
    if (!m_menuVisible) return;

    ImGui::Begin("Scene Parameters");
    ImGui::End();
}


void SceneParticles::initializeShader()
{
    // Particule shader
    {
        std::string vertexCode = readFile("shaders/particle.vs.glsl");
        std::string geometryCode = readFile("shaders/particle.gs.glsl");
        std::string fragmentCode = readFile("shaders/particle.fs.glsl");

        ShaderObject vertex(GL_VERTEX_SHADER, vertexCode.c_str());
        ShaderObject geometry(GL_GEOMETRY_SHADER, geometryCode.c_str());
        ShaderObject fragment(GL_FRAGMENT_SHADER, fragmentCode.c_str());
        m_particuleShaderProgram.attachShaderObject(vertex);
        m_particuleShaderProgram.attachShaderObject(geometry);
        m_particuleShaderProgram.attachShaderObject(fragment);
        m_particuleShaderProgram.link();

        m_modelViewLocationParticle = m_particuleShaderProgram.getUniformLoc("modelView");
        m_projectionLocationParticle = m_particuleShaderProgram.getUniformLoc("projection");
    }
    
    {
        std::string vertexCode = readFile("shaders/transformFeedback.vs.glsl");

        ShaderObject vertex(GL_VERTEX_SHADER, vertexCode.c_str());
        m_transformFeedbackShaderProgram.attachShaderObject(vertex);

        const char* varyings[] = {
            "positionMod",
            "velocityMod",
            "colorMod",
            "sizeMod",
            "timeToLiveMod"
        };
        m_transformFeedbackShaderProgram.setTransformFeedbackVaryings(varyings, 5, GL_INTERLEAVED_ATTRIBS);
        
        m_transformFeedbackShaderProgram.link();

        m_timeLocationTransformFeedback = m_transformFeedbackShaderProgram.getUniformLoc("time");
        m_dtLocationTransformFeedback = m_transformFeedbackShaderProgram.getUniformLoc("dt");
    }
}

void SceneParticles::initializeTexture()
{
    m_flameTexture.setFiltering(GL_LINEAR);
    m_flameTexture.setWrap(GL_CLAMP_TO_EDGE);
}

