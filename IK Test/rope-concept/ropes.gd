extends ColorRect
var type : int
#set type based on the following:
#type 0: default, horizontal and no interaction
#type 1: up and down
#type 2: upper corner
#type 3: lower corner

func _ready():
	var node = Area2D.new();
	var node2 = CollisionShape2D.new()
	var node3 = RectangleShape2D.new()
	node.position = Vector2(0,0)
	node3.size = Vector2(12,12)
	node2.shape = node3;
	
	add_child(node)
	node.add_child(node2)

func _process(float):
	pass;
	
func _draw():
	draw_string(ThemeDB.fallback_font, position-global_position, str(type), HORIZONTAL_ALIGNMENT_LEFT, -1, 6)
