extends RemoteTransform2D

var moving_toward_player = false
var player

@export var speed = 30

func _physics_process(delta: float) -> void:
	
	
	if moving_toward_player && player:
		position = position.move_toward(player.position, delta * speed)
		
	if  moving_toward_player && player && position.distance_to(player.position) < 2 :
		moving_toward_player = false
		top_level = false
		position = Vector2(0,0)
	

func gradually_move_to_player(player_in: Node2D) :
	player = player_in
	moving_toward_player = true
