extends Node
class_name Rope
var anchor_location : Vector2

@onready var first_segment: RopeSegment = $RopeSeg0
@onready var last_segment : RopeSegment = first_segment
@onready var end_node: RigidBody2D = $EndNode
@onready var rope_render: Line2D = $RopeRender
@onready var base_node: RopeSegment = $BaseNode
@onready var base_pin_joint_2d: PinJoint2D = $BaseNode/PinJoint2D



const ROPE_SEGMENT = preload("res://Scenes/rope_segment.tscn")

func _ready() -> void:
	rope_render.top_level = true
	base_node.rope = self
	pass

var timer = 0
var moving_base = false
func _process(delta: float) -> void:
	if timer > 60 :
		if !end_node.freeze :
			remove_rope_segment()
		if moving_base :
			
			var next_segment = base_node.get_next_segment().get_next_segment()
			base_node.set_next_segment(next_segment)
			moving_base = false
			
		timer = 0
	timer += 1
	
	if moving_base :
		base_node.global_position = base_node.global_position.move_toward(base_node.get_next_segment().get_next_segment().pin_hole.global_position, 0.2)
	
	update_renderer_points_recursive(last_segment)
	
func update_renderer_points_recursive(segment: RopeSegment, index: int = 0) :
	if segment == null || segment == end_node :
		return
	
	rope_render.set_point_position(index, segment.global_position)
	
	update_renderer_points_recursive(segment.get_next_segment(), index + 1)
	pass
	
func move_base_up_chain() :
	if base_node.get_next_segment().get_next_segment() :
		moving_base = true
	else : moving_base = false



func add_rope_segment() :
	var new_seg = ROPE_SEGMENT.instantiate()
	add_child(new_seg)
	new_seg.rope = self
	
	new_seg.set_next_segment(last_segment)
	
	base_pin_joint_2d.node_b = new_seg.get_path()
	last_segment = new_seg
	rope_render.add_point(new_seg.global_position)
	
func add_rope_segments(count: int) :
	for i in count :
		add_rope_segment()

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
