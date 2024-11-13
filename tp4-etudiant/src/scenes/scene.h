#ifndef SCENE_H
#define SCENE_H

#include "window.h"

class Scene
{
public:
    Scene()
    {}
    virtual ~Scene() = default;
    
    virtual void run(Window& w) = 0;
    
protected:

};

#endif // SCENE_H
