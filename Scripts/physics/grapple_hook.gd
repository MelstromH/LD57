extends RopeSegment
class_name GrappleSegment

@onready var player: PlayerBody = $"../.."
@onready var tile_map_layer: TileMapLayer = $"../../../TileMapLayer"

signal latch_signal()

func _ready() -> void:
	pin_hole = self

func get_next_segment() -> RopeSegment:
	return null

func _on_grapple_detector_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var coords = tile_map_layer.get_coords_for_body_rid(body_rid)
	var tile = tile_map_layer.get_cell_tile_data(coords)

	if tile && tile.get_custom_data("Mantleable") == true :
		print("grapple collided")
		set_deferred("freeze", true)
		linear_velocity = linear_velocity * 0
		emit_signal("latch_signal")
