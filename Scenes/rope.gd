extends Node

var anchor_location : Vector2

@onready var first_segment: RopeSegment = $RopeSeg0
@onready var last_segment : RopeSegment = first_segment
@onready var base_pin_joint_2d: PinJoint2D = $BaseNode/BasePinJoint2D
@onready var end_node: RigidBody2D = $EndNode
@onready var rope_render: Line2D = $RopeRender


const ROPE_SEGMENT = preload("res://Scenes/rope_segment.tscn")

func _ready() -> void:
	#var pos = end_node.global_position
	#end_node.top_level = true
	#end_node.position = pos
	
	rope_render.top_level = true
	pass

var timer = 0
func _process(delta: float) -> void:
	if timer > 20 :
		remove_rope_segment()
		timer = 0
	timer += 1
	
	update_renderer_points_recursive(last_segment)
	
func update_renderer_points_recursive(segment: RopeSegment, index: int = 0) :
	if !segment :
		rope_render.set_point_position(index, end_node.global_position)
		return
	
	rope_render.set_point_position(index, segment.global_position)
	update_renderer_points_recursive(segment.get_next_segment(), index + 1)
	pass


func add_rope_segment() :
	var new_seg = ROPE_SEGMENT.instantiate()
	add_child(new_seg)
	new_seg.global_position = last_segment.pin_hole.global_position
	new_seg.pin_joint_2d.node_a = last_segment.get_path()
	new_seg.global_position = base_pin_joint_2d.global_position + (new_seg.global_position - new_seg.pin_hole.global_position)
	base_pin_joint_2d.node_b = new_seg.get_path()
	last_segment = new_seg
	rope_render.add_point(new_seg.global_position)

func remove_rope_segment():
	if last_segment == first_segment:
		return # No segment to remove
		
	var previous_segment = last_segment.get_next_segment()
	
	if previous_segment == null :
		return
		
	previous_segment.global_position = base_pin_joint_2d.global_position + (previous_segment.global_position - previous_segment.pin_hole.global_position)
	
	base_pin_joint_2d.node_b = previous_segment.get_path()

	remove_child(last_segment)
	
	rope_render.remove_point(rope_render.points.size() -1)
	
	last_segment = previous_segment
