extends CharacterBody2D
var target = self;
var throw = false;
var gravity = 0;
var pos_prev : Vector2 
var spawn = false;
var initialize = false;
var length = 50;
var dir : int;
var node = ""
var anchor = position;

func _ready():
	pass;
	if name != "Rope":
		var b = ColorRect.new();
		add_child(b);
	else:
		name = "Rope" + str(length)

func _process(float):
	if name != "Rope" + str(length):
		if !get_node("../TileMapLayer").get_cell_tile_data(get_node("../TileMapLayer").local_to_map(position+Vector2(0,8))):
			velocity.y = 80;
		target = get_node("../Rope" + str(int(name.erase(0, 4))+1))
		if position.distance_to(target.position) > 8:
			position = target.position.move_toward(position, 8)
		#elif position.distance_to(target.position) < 8:
		#	position = target.position.move_toward((position.max(target.position) - (position.min(target.position)*1000)), 8)
		#	print("CLOSE")
	else:
		if initialize == false:
			for i in length:
				var a = duplicate();
				a.set_script(load("res://snake_test.gd"));
				a.set_name("Rope" + str(length-(i+1)))
				get_node("../../Test Scene").add_child(a);
				
			initialize = true;
		if Input.is_action_just_pressed("Throw"):
			if throw == false:
				throw = true;
				gravity = 0
				velocity = (global_position - pos_prev).normalized() * 100;
				print(pos_prev)
				print(position)
			else:
				spawn = false;
				throw = false;
				node.destroy = true;
		pos_prev = position;
	
		if throw == false:
			#position = get_global_mouse_position()
			if !get_node("../TileMapLayer").get_cell_tile_data(get_node("../TileMapLayer").local_to_map(Vector2(get_global_mouse_position().x, position.y))):
				position.x = get_global_mouse_position().x;
			if !get_node("../TileMapLayer").get_cell_tile_data(get_node("../TileMapLayer").local_to_map(Vector2(position.x, get_global_mouse_position().y))):
				position.y = get_global_mouse_position().y;

		else:
			if !get_node("../TileMapLayer").get_cell_tile_data(get_node("../TileMapLayer").local_to_map(position)):
				velocity.y += gravity;
				if gravity < 1000:
					gravity += 0.04;
			if is_on_wall() or is_on_ceiling() or is_on_floor():
				if velocity.x < 0:
					dir = 1;
				else:
					dir = -1;
				velocity = Vector2(0,0);
				if spawn == false:
					spawn = true;
					node = load("res://character_body_2d.tscn").instantiate()
					node.dir = dir;
					node.position = position
					get_node("../../Test Scene").add_child(node)
	if anchor != position:
		#position = position.move_toward(anchor, 10);
		pass;
	move_and_slide();
	
