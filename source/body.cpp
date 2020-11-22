#include "body.h"

using namespace godot;

void Body::_register_methods()
{
    register_method("_process", &Body::_process);

    register_property <Body, float> ("elasticity", &Body::elasticity, 0.6);
}

Body::Body()
{
	velocity = Vector3(0, 0, 0);
}

Body::~Body()
{
}

void Body::_init()
{
	elasticity = 0.6;
}

void Body::_process(float delta)
{
	velocity += Vector3(0, -0.00001, 0);

	auto obj = move_and_collide(velocity);
	if (obj.ptr())
		velocity *= -elasticity;
}
