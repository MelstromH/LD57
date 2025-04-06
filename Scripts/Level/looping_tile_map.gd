@tool
extends TileMapLayer

@export var player : Node
@export var middle_index : Vector2i
@export var width : int
@export var update_interval : int = 60
var timer : int = 0
var left_bound
var right_bound

func _ready() :
	width = get_used_rect().size.x
	print("width: " + str(width))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not Engine.is_editor_hint() :
		middle_index = local_to_map(player.position)
		
		if middle_index.x > width * 0.75 + 1 :
			
			print(middle_index.x)
			var new_pos = Vector2i(width * 0.25, middle_index.y)
			player.position = Vector2i(map_to_local(new_pos).x, player.position.y)
			
			
		
		if middle_index.x < width * 0.25 - 1 :
			print(middle_index.x)
			var new_pos = Vector2i(width * 0.75, middle_index.y)
			player.position = Vector2i(map_to_local(new_pos).x, player.position.y)

		
	
	else : 
		if timer >= update_interval :
			timer = 0
			
			width = get_used_rect().size.x
			
			left_bound = map_to_local(Vector2i(width * .25, 0))
			right_bound = map_to_local(Vector2i(width * .75, 0))
			
			
		timer += 1
	
func _draw() :
	
	if Engine.is_editor_hint() :
		
		draw_line(right_bound, Vector2(right_bound.x, 1000), Color.AQUA, 2, false)
		draw_line(left_bound, Vector2(left_bound.x, 1000), Color.AQUA, 2, false)
#func update_level() :
	#
	#var array = get_used_cells()
	#var rect = get_used_rect()
	#
	#var ilist = ""
	#
	#for i in range(rect.position.x, rect.size.x) :
		#
		#ilist += str(i) + ", "
		#
		#if  i > middle_index + width || i < middle_index - width :
			#var slice = array.filter(func(vector) : return is_in_slice(vector, i))
			#
			#for vector in slice :
				#set_cell(vector, -1)
		#
		#if i < middle_index - (width/2 + 1) :
			#
			#var slice = array.filter(func(vector) : return is_in_slice(vector, i))
			#
			#send_slice_to_opposite(slice)
			#
		#elif i > middle_index + (width/2 - 1) :
			#
			#var slice = array.filter(func(vector) : return is_in_slice(vector, i))
			#
			#send_slice_to_opposite(slice)
			#
	#print(ilist)
#
#
#func send_slice_to_opposite(slice : Array[Vector2i]) :
	#
	#for vector in slice :
				#
		#var tile_data = get_cell_tile_data(vector)
		#
		#var difference = vector.x - middle_index 
		##print(difference)
		#
		#var new_x = middle_index + width + difference
		#var newVector = Vector2i(new_x, vector.y)
		#
		#set_cell(newVector, tile_set.get_source_id(0), get_cell_atlas_coords(vector))
		#
		#set_cell(vector, -1)
		#
		#
		#
		
	
#func is_in_slice(vector: Vector2i, index: int) :
	#if vector.x == index :
		#return true
	#else :
		#return false
