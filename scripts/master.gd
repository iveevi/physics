extends Spatial

export (int) var width;
export (int) var length;

export (float) var wi;
export (float) var li;

export (float) var mass;
export (float) var k;
export (float) var r;

export (float) var air;
export (float) var fs;
export (float) var fk;

var point_mass = 0;

var points = [];

var sheet_v = [];
var sheet_h = [];

var dx = [-1, 1, 0, 0];
var dy = [0, 0, -1, 1];

onready var body = load("res://body.tscn");

func _ready():
	point_mass = mass / (width * length);
	
	for i in range(0, width):
		var pt = [];
		
		for j in range(0, length):
			var particle = body.instance();
			
			particle.transform.origin = transform.origin + Vector3(i * wi - wi * width / 2, 0, j * li - li * length/2);
			
			# particle.pt_mass = point_mass;
			
			pt.append(particle);
			
			add_child(particle);
		
		points.append(pt);
	
	print(points);
	
	# Assign neighbors
	for i in range(0, width):
		for j in range(0, length):
			for k in range(0, 4):
				var ni = i + dx[k];
				var nj = j + dy[k];
				
				if ni >= 0 and ni < width and nj >= 0 and nj < length:
					points[i][j].neighbors.append(points[ni][nj]);
	
	for i in range(0, width):
		var drawer = ImmediateGeometry.new();
			
		get_node("sheets").add_child(drawer);
			
		sheet_h.append(drawer);
	
	for i in range(0, length):
		var drawer = ImmediateGeometry.new();
			
		get_node("sheets").add_child(drawer);
			
		sheet_v.append(drawer);
	
	print(sheet_v);
	print(sheet_h);

# Body variables
var scl = 0.002;

# Spring model
func model(diff):
	var d = diff.length();
	
	if d > r:
		return k * (d - r) * diff.normalized();
	
	return Vector3(0, 0, 0);

# Kernel
func kernel(pt, delta):
	# Kernel function
	var force = Vector3(0, 0, 0);
	
	# if pt.get_slide_count() == 0:
	#	force += air * pow(pt.velocity.length(), 2) * pt.velocity.normalized();
	
	for obj in pt.neighbors:
		var diff = obj.transform.origin - pt.transform.origin;
		
		# print(str(diff) + "\t" + str(diff.length()));
		force += model(diff);
	
	force -= Vector3(0, 9.81 * point_mass, 0);
	
	if pt.get_slide_count() > 0:
		force += Vector3(0, 9.81 * point_mass, 0);
		if force.length() > 9.81 * point_mass * fs:
			force -= (fk * 9.81 * point_mass) * force.normalized();
		elif force.length() < 1e-9 and pt.velocity.length() > 0:
			force -= (fk * 9.81 * point_mass) * pt.velocity.normalized();
		else:
			force = Vector3(0, 0, 0);
	
	pt.velocity += scl * (force/point_mass);
	
	pt.move_and_slide(pt.velocity);

# Physics
func _physics_process(delta):
	for i in range(0, width):
		for j in range(0, length):
			kernel(points[i][j], delta);

# Redraw the sheet
func _process(delta):
	for i in range(0, width):
		sheet_h[i].clear();
		
		sheet_h[i].begin(Mesh.PRIMITIVE_LINE_STRIP);
		for j in range(0, length):
			sheet_h[i].add_vertex(points[i][j].transform.origin);
			
		sheet_h[i].end();
	
	for i in range(0, length):
		sheet_v[i].clear();
		
		sheet_v[i].begin(Mesh.PRIMITIVE_LINE_STRIP);
		for j in range(0, width):
			sheet_v[i].add_vertex(points[j][i].transform.origin);
			
		sheet_v[i].end();
