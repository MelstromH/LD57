extends RigidBody2D
class_name RopeSegment

@onready var pin_hole: Node2D = $PinHole
@onready var pin_joint_2d: PinJoint2D = $PinJoint2D

func _process(delta: float) -> void:
	pass
	
func get_next_segment() -> RopeSegment:
	return get_node(pin_joint_2d.node_a)
