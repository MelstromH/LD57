extends CharacterBody2D
var tile : Node
var shapecast : Node
var climb : bool
var gravity = 0;

func _ready():
	shapecast = get_node("CollissionShapecast");

func _process(float):
	climb = false;
	velocity = Vector2(0,0);
	if shapecast.is_colliding():
		for i in shapecast.get_collision_count():
			match shapecast.get_collider(i).get_parent().type:
				1:
					climb = true;
				2: 
					climb = true;
				3:
					climb = true;
	if Input.is_action_pressed("left"):
		velocity.x = -50
	if Input.is_action_pressed("right"):
		velocity.x = 50;
	if Input.is_action_pressed("up"):
		velocity.y = -50;
	if Input.is_action_pressed("down"):
		velocity.y = 50;
	if !is_on_floor():
		if !(Input.is_action_pressed("up") && climb == true):
			velocity.y = gravity;
			gravity += 5;
		else:
			gravity = 0;
	else:
		gravity = 0;
	move_and_slide()
