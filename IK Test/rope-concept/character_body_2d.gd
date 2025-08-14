extends CharacterBody2D
var track = true;
var tile_map : TileMapLayer
var coords = Vector2(-1,-1);
var ud = 0;
var lr = 0;
var dir = -1;
var length = 30;
var points = [];
var destroy = false;

func _ready():
	#velocity = Vector2(45,-65);
	tile_map = get_node("../TileMapLayer")
	points.resize(length);

func _process(float) -> void:
	move_and_slide()
	
	
	
	get_node("ropeStart").position = tile_map.map_to_local(tile_map.local_to_map(to_local(get_global_mouse_position())));
	
	#coords = tile_map.get_coords_for_body_rid(get_rid());
	
	if is_on_floor():
		if velocity.y > 0:
			velocity.y = 0;
		velocity.x = 0;
	
	else: 
		if velocity.y < 100:
			#velocity.y += 1;
			pass;
	
	if track == true:
		for i in length:
			var type : int #type of rope segment you'll be spawning
			#find the current position of the tracker, offset by u and d (up and down)
			var pos = tile_map.map_to_local(tile_map.local_to_map(global_position+Vector2(16*lr,16*ud)));
			#check each direction, using a function that returns a cell's data object or -1 if there is no cell
			var up = tile_map.get_cell_tile_data(tile_map.local_to_map(pos+Vector2(0,-16)))
			var right = tile_map.get_cell_tile_data(tile_map.local_to_map(pos+Vector2(16,0)))
			var bot_right = tile_map.get_cell_tile_data(tile_map.local_to_map(pos+Vector2(16,16)))
			var down = tile_map.get_cell_tile_data(tile_map.local_to_map(pos+Vector2(0,16)))
			var left = tile_map.get_cell_tile_data(tile_map.local_to_map(pos+Vector2(-16,0)))
			var bot_left = tile_map.get_cell_tile_data(tile_map.local_to_map(pos+Vector2(-16,16)))
			
			#change direction based on surroundings
			#also set type based on the following:
			#type 0: default, horizontal and no interaction
			#type 1: up and down
			#type 2: upper corner
			#type 3: lower corner
			if !down && !up && left && !right: #left occupied
				ud += 1;
				type = 1;
			elif down && !up && left && !right: #down and left occupied
				lr += dir;
				type = 3;
			elif down && !up && !left && !right: #down occipied
				lr += dir;
			elif down && !up && !left && right: #down and right occupied
				lr += dir;
				type = 3;
			elif !down && !up && !left && right: #right occupied
				ud += 1;
				type = 1;
			elif !down && !up && !left && !right && !bot_right && !bot_left: #open air
				ud += 1;
				type = 1;
			elif !down && !up && !left && !right && !bot_left && bot_right: #bottom right occupied
				ud += 1;
				type = 2;
			elif !down && !up && !left && !right && bot_left && !bot_right: #bottom left occupied
				ud += 1;
				type = 2;
			
			var inst = ColorRect.new();
			inst.set_script(load("res://ropes.gd"))
			inst.size = Vector2(1, 1)
			inst.global_position = pos;
			inst.type = type;
			#inst.anchor = i;
			get_node("../../Test Scene").add_child(inst)
			print(str(inst.name))
			points[i] = get_node(str(inst.name));
		track = false;
		lr = 0;
		ud = 0;
	
	if destroy == true:
		pass
