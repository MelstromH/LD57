extends RopeSegment
class_name RopeBase

@onready var player: PlayerBody = $".."
@onready var tile_map_layer: TileMapLayer = $"../../TileMapLayer"

func _process(delta: float) -> void:
	
	if freeze : 
		global_position = player.global_position
		
	
	#if next_segment :
		#global_position = next_segment.pin_hole.global_position
func detach_rope() :
	next_segment = null
	pin_joint_2d.node_b = ""
	
func hang_player() :
	var pos = player.ropes.base_node.global_position
	top_level = true
	position = pos
	set_deferred("freeze", false)

func get_next_segment() -> RopeSegment:
	if !next_segment :
		var path = pin_joint_2d.node_b
		var node = pin_joint_2d.get_node(path)
		next_segment = node
		return node
	else :
		return next_segment

func set_next_segment(next_seg : RopeSegment) :
	print(next_seg)
	global_position = next_seg.pin_hole.global_position
	pin_joint_2d.node_b = next_seg.get_path()
	next_segment = next_seg
	previous_segment = next_seg.previous_segment
