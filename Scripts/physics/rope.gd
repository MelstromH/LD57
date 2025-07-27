extends Node
class_name Rope
var anchor_location : Vector2

@onready var first_segment: RopeSegment = $RopeSeg0
@onready var last_segment : RopeSegment = first_segment
@onready var end_node: RigidBody2D = $EndNode
@onready var rope_render: Line2D = $RopeRender
@onready var base_node: RopeSegment = $"../RopeConnector"
@onready var base_pin_joint_2d: PinJoint2D = $"../RopeConnector/PinJoint2D"



const ROPE_SEGMENT = preload("res://Scenes/rope_segment.tscn")
const GRAPPLE_SEGMENT = preload("res://Scenes/grapple_hook.tscn")

func _ready() -> void:
	rope_render.top_level = true
	base_node.rope = self
	pass

var timer = 0
var moving_base_up = false
var moving_base_down = false
func _process(delta: float) -> void:
	if timer > 60 :
		if !end_node.freeze :
			remove_rope_segment()
		if moving_base_up :
			
			var next_segment = base_node.get_next_segment().get_next_segment()
			base_node.set_next_segment(next_segment)
			moving_base_up = false
		
		if moving_base_down :
			
			var prev_segment = base_node.previous_segment
			base_node.set_next_segment(prev_segment)
			moving_base_down = false
		
		timer = 0
	timer += 1
	
	if moving_base_up :
		base_node.global_position = base_node.global_position.move_toward(base_node.get_next_segment().get_next_segment().pin_hole.global_position, 0.2)
		
	if moving_base_down :
		base_node.global_position = base_node.global_position.move_toward(base_node.previous_segment.previous_segment.pin_hole.global_position, 0.2)
	
	update_renderer_points_recursive(last_segment)
	

	if get_desired_rope_length(last_segment, 0) < get_actual_length() * 0.8 :
		end_node.linear_velocity = 20 * end_node.global_position.direction_to(last_segment.global_position)
		print("Desired: " + str(get_desired_rope_length(last_segment, 0)) + ", Actual: " + str(get_actual_length()))
		pass
	
func update_renderer_points_recursive(segment: RopeSegment, index: int = 0) :
	if segment == null || segment == end_node :
		return
	
	rope_render.set_point_position(index, segment.global_position)
	
	update_renderer_points_recursive(segment.get_next_segment(), index + 1)
	pass
	
func move_base_up_chain() :
	if base_node.get_next_segment().get_next_segment() :
		moving_base_up = true
	else : moving_base_up = false
	
func move_base_down_chain() :
	if base_node.previous_segment && base_node.previous_segment.previous_segment :
		moving_base_down = true
	else : moving_base_down = false

func add_rope_segment() :
	var new_seg = ROPE_SEGMENT.instantiate()
	add_child(new_seg)
	new_seg.rope = self
	
	new_seg.set_next_segment(last_segment)
	
	base_node.global_position = new_seg.global_position
	base_pin_joint_2d.node_b = new_seg.get_path()
	
	last_segment = new_seg
	rope_render.add_point(new_seg.global_position)
	
func add_rope_segment_at_end() :
	var new_seg = ROPE_SEGMENT.instantiate()
	add_child(new_seg)
	new_seg.rope = self
	
	first_segment.set_next_segment(new_seg)
	
	var pos = end_node.global_position
	end_node.global_position = new_seg.global_position
	new_seg.set_next_segment(end_node)
	end_node.global_position = pos
	
	first_segment = new_seg
	rope_render.add_point(new_seg.global_position)
	
	
func add_rope_segments(count: int) :
	for i in count :
		add_rope_segment()
		
func add_rope_segments_at_end(count: int) :
	for i in count :
		add_rope_segment_at_end()

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
	
func get_desired_rope_length(segment: RopeSegment, length: float) -> float :
	if segment == null || segment == end_node :
		return length
	
	length += segment.natural_distance
	
	return get_desired_rope_length(segment.get_next_segment(), length)
	
func get_actual_length() -> float :
	return last_segment.global_position.distance_to(end_node.global_position)
	
func detach_base_node():
	base_node.position = Vector2(0,0)
	base_node.set_deferred("freeze", true)
	base_node.top_level = false
	base_node.detach_rope()
	
func arm_grapple():
	var pos = end_node.global_position
	end_node.top_level = true
	end_node.position = pos
	end_node.freeze = false
	end_node.can_latch = true
	
func anchor_rope_at_location(location: Vector2):
	end_node.top_level = true
	end_node.global_position = location
	set_deferred("freeze", true)
	pass

func move_base_to_top():
	base_node.global_position = first_segment.previous_segment.previous_segment.global_position
	base_pin_joint_2d.node_b = first_segment.previous_segment.previous_segment.get_path()
	base_node.previous_segment = first_segment.previous_segment
	pass
