extends CharacterBody2D


#animation
enum CharacterState {Standing, Stopping, Starting, Walking, Running, Jumping}
var character_state = CharacterState.Standing
var direction_facing = 1

#vertical
@export var SPEED = 25 
@export var BASE_JUMP_VELOCITY = -25
var actual_jump_velocity
var can_mantle = false
var previous_frame_falling_speed = 0

#horizontal
@export var momentum_max : float = 2.5
var momentum = 0;
@export var momentum_decay : float = 0.1
@export var momentum_damping : float = 5
@export var friction : float = 0.1

#other nodes
@export var tile_map : TileMapLayer
@onready var state_container = $StateContainer

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and ( is_on_floor() || can_mantle) :
		if can_mantle : 
			actual_jump_velocity = BASE_JUMP_VELOCITY * 4
		else : 
			actual_jump_velocity = BASE_JUMP_VELOCITY
	
		if  abs(momentum) >= (momentum_max * 0.8) && !can_mantle : 
			velocity.y = actual_jump_velocity * 1.3
		else :
			velocity.y = actual_jump_velocity
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		#make sure character isn't going too fast
		if direction * momentum >= 0 :
			#this function ensures that acceleration isn't too abbrupt
			momentum += (direction/10) * ( abs(momentum)/momentum_damping + 0.1)
			#character state stuff for animations
			if momentum > 2 || momentum < -2 :
				character_state = CharacterState.Running
			else : 
				character_state = CharacterState.Walking
				
		else :
			momentum = move_toward(momentum, 0, friction)
			character_state = CharacterState.Stopping
		
		momentum = clamp(momentum, -2.5, 2.5)
		
	else:
		momentum = move_toward(momentum, 0, friction)
		
		if momentum == 0 :
			character_state = CharacterState.Standing
		else :
			character_state = CharacterState.Stopping
			
	#character facing direction
	set_direction_facing(direction)
	
	detect_fall_damage()
	
	
	velocity.x = (SPEED * momentum) 
	move_and_slide()
	
func set_direction_facing(direction_input: int) :
	if direction_input && direction_facing != direction_input :
		scale.x = -1
		direction_facing = direction_input
		
func detect_fall_damage() :
	if velocity.y - previous_frame_falling_speed < -100  :
		var damage : int = previous_frame_falling_speed / 100
		
		state_container.damage(damage)
	
	previous_frame_falling_speed = velocity.y	
	
	if velocity.y > 500 : 
		state_container.damage(5)

	
func _on_mantle_detector_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var coords = tile_map.get_coords_for_body_rid(body_rid)
	var tile = tile_map.get_cell_tile_data(coords)

	if tile && tile.get_custom_data("Mantleable") == true :
		can_mantle = true

func _on_mantle_detector_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var coords = tile_map.get_coords_for_body_rid(body_rid)
	var tile = tile_map.get_cell_tile_data(coords)

	if tile && tile.get_custom_data("Mantleable") == true :
		can_mantle = false
		
