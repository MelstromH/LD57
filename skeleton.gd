extends CharacterBody2D

var player_state

var previous_frame_falling_speed = 0

var crumble_timer = 0
@export var crumble_threshold = 120
	
func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if velocity.y - previous_frame_falling_speed < -200  :
		die()
		
	previous_frame_falling_speed = velocity.y
	
	move_and_slide()
	
	if velocity.y > 500  : 
		die()
	
func die() :
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void: 
	if body.name == "Player" :
		player_state.add_scrap()
		print("scrap added " + str(player_state.number_scraps))
		die()
