extends CharacterBody2D

var player_state

var previous_frame_falling_speed = 0

@onready var area_2d: Area2D = $Area2D

var crumble_timer = 0
@export var crumble_threshold = 120

@export var scrap_granted = 1

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	area_2d.monitoring = true
	
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
		if not player_state :
			player_state = body.get_node("StateContainer")
		player_state.add_scrap(scrap_granted)
		print("scrap added " + str(player_state.number_scraps))
		die()
