extends KinematicBody

var pt_mass = 0;

var velocity = Vector3(0, 0, 0);

var neighbors = [];

func _ready():
	pass

var acceleration;
var force;

var scl = 0.01;

func _physics_process(delta):
	force = Vector3(0, 0, 0);
	
	# Normal force
	if move_and_collide(velocity):
		force = Vector3(0, 9.81 * pt_mass, 0);
	else:
		force -= get_parent().air * pow(velocity.length(), 2) * velocity.normalized();
	
	for obj in neighbors:
		var diff = obj.transform.origin - transform.origin;
		
		if diff.length() > get_parent().r:
			force -= get_parent().k * (get_parent().r - diff.length()) * diff.normalized();
	
	force -= Vector3(0, 9.81 * pt_mass, 0);
	
	acceleration = force/pt_mass;
	
	velocity += scl * acceleration * delta;
