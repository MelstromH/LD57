extends Node2D

@onready var ladder = $"Ladder"
@onready var player_state = get_node("%StateContainer")

var previous_frame_falling_speed = 0

var crumble_timer = 0
@export var crumble_threshold = 120

func _ready() -> void:
	hide_ladder()
	
func _physics_process(delta: float) -> void:
	
	if not ladder || not ladder.is_inside_tree() : 
		return
	
	if not ladder.is_on_floor():
		ladder.velocity += ladder.get_gravity() * delta
		
	if ladder.velocity.y - previous_frame_falling_speed < -200  :
		die()
		
	previous_frame_falling_speed = ladder.velocity.y
	
	ladder.move_and_slide()
	
	if ladder.velocity.y > 500  : 
		die()
		
	if player_state.climbed : 
		crumble_timer += 1
		
		if crumble_timer > crumble_threshold :
			die()
			crumble_timer = 0
	
	
func die() :
	hide_ladder()

func handle_ladder() : 
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, Vector2(global_position.x, -8))
	
	var result = space_state.intersect_ray(query)
	
	print("ray collided with: " + str(result))
	
	if !result && player_state.number_scraps >= player_state.scrap_ladder_threshold:
		player_state.number_scraps = 0
		show_ladder()
		
		
func hide_ladder() :
	remove_child(ladder)
	ladder.top_level = false
	ladder.position = Vector2i(0,0)
	
func show_ladder() :
	add_child(ladder)
	ladder.top_level = true
	ladder.position = global_position
	player_state.climbed = false


func _on_area_2d_body_entered(body: Node2D) -> void: 
	if body.name == "Player" :
		player_state.on_ladder = true
		print("can climb: " + str(player_state.on_ladder))

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player" :
		player_state.on_ladder = false
