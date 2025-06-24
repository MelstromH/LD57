extends RigidBody2D
class_name RopeSegment

@onready var pin_hole: Node2D = $PinHole
@onready var pin_joint_2d: PinJoint2D = $PinJoint2D

var rope : Rope
var next_segment : RopeSegment
var previous_segment : RopeSegment
var natural_distance : float

func _ready() -> void:
	var pos = global_position
	top_level = true
	global_position = pos
	natural_distance = pin_hole.global_position.distance_to(pin_joint_2d.global_position)

func _process(delta: float) -> void:

	pass
	
func get_next_segment() -> RopeSegment:
	if !next_segment :
		var path = pin_joint_2d.node_a
		var node = pin_joint_2d.get_node(path)
		next_segment = node
		return node
	else :
		return next_segment

func set_next_segment(next_seg : RopeSegment) :
	global_position = next_seg.pin_hole.global_position
	pin_joint_2d.node_a = next_seg.get_path()
	global_position = next_seg.pin_hole.global_position + (global_position - pin_hole.global_position)
	next_segment = next_seg
	next_seg.previous_segment = self
