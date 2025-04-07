extends CharacterBody2D
#animation
@onready var animation_controller = $AnimatedSprite2D
var direction_facing = 1

var has_mantled = false

#vertical
@export var SPEED = 25 
@export var BASE_JUMP_VELOCITY = -35
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
@onready var ladder_spawn = $"LadderSpawn"
@onready var mantle_location = $"MantleTeleportLocation"

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() && not state_container.on_ladder:
		velocity += get_gravity() * delta * state_container.gravity_multiplier
		
		animation_controller.set_state(PlayerState.CharacterState.LongJumping)
			
	elif not is_on_floor() : 
		velocity.y = 50
		state_container.climbed = true
		animation_controller.set_state(PlayerState.CharacterState.Walking)
		
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and ( is_on_floor() || can_mantle) && !animation_controller.locked:
		handle_jump()
	
			
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if state_container.on_ladder && Input.is_action_pressed("Climb") :
		velocity.y = -50
		state_container.climbed = true

	
	var direction := Input.get_axis("Left", "Right")

	if direction && !animation_controller.locked:
		#make sure character isn't going too fast
		if direction * momentum >= 0 :
			#this function ensures that acceleration isn't too abbrupt
			momentum += (direction/10) * ( abs(momentum)/momentum_damping + 0.1)
			#character state stuff for animations
			if momentum > 2 || momentum < -2 && is_on_floor():
				animation_controller.set_state(PlayerState.CharacterState.Running)
			elif is_on_floor() : 
				animation_controller.set_state(PlayerState.CharacterState.Walking)
				
		else :
			momentum = move_toward(momentum, 0, friction)
			animation_controller.set_state(PlayerState.CharacterState.Walking)
		
		momentum = clamp(momentum, -2.5, 2.5)
		
	elif !animation_controller.locked:
		momentum = move_toward(momentum, 0, friction)
		
		if momentum == 0 && is_on_floor() :
			animation_controller.set_state(PlayerState.CharacterState.Standing)
		#else :
			##animation_controller.set_state(PlayerState.CharacterState.Walking)
	
		
	#character facing direction
	set_direction_facing(direction)
	
	detect_fall_damage()
	
	velocity.x = (SPEED * momentum) 
	move_and_slide()
	
	if Input.is_action_just_released("Ladder") : 
		ladder_spawn.handle_ladder()
		
	if is_on_floor() :
		state_container.last_grounded_location = tile_map.map_to_local(tile_map.local_to_map(position))

func handle_jump() :
	
	
	if can_mantle : 
		momentum = 0
		animation_controller.set_state(PlayerState.CharacterState.Mantling)
		position = mantle_location.global_position
	else : 
		actual_jump_velocity = BASE_JUMP_VELOCITY	
		
	if  abs(momentum) >= (momentum_max * 0.7) && !can_mantle : 
		animation_controller.set_state(PlayerState.CharacterState.LongJumpStarting)
		momentum = momentum * 0.7
		await animation_controller.wait_for_animation()
		if is_on_floor() :
			animation_controller.set_state(PlayerState.CharacterState.LongJumping)
			#animation_controller.locked = true
			momentum = momentum * 1.7
			velocity.y = actual_jump_velocity * 1.3

	elif !can_mantle :
		animation_controller.set_state(PlayerState.CharacterState.Hopping)
		await animation_controller.wait_for_animation()
		if is_on_floor() && velocity != null && actual_jump_velocity:
			velocity.y = actual_jump_velocity * 1.
		
	
func set_direction_facing(direction_input: int) :
	if direction_input && direction_facing != direction_input && !animation_controller.locked :
		scale.x = -1
		direction_facing = direction_input
		
func detect_fall_damage() :
	if animation_controller.current_state == PlayerState.CharacterState.Mantling:
		previous_frame_falling_speed = 0
		return
		
	
	if velocity.y - previous_frame_falling_speed < -150 && previous_frame_falling_speed > 0 :
		var damage : int = previous_frame_falling_speed / 150
		
		momentum = 0
		
		if  damage >= state_container.current_health : 
			animation_controller.set_state(PlayerState.CharacterState.LethalLanding)
			await animation_controller.wait_for_animation()
			state_container.damage(damage)
		else : 
			state_container.damage(damage)
			animation_controller.set_state(PlayerState.CharacterState.HardLanding)
	elif velocity.y - previous_frame_falling_speed < -50 && previous_frame_falling_speed > 0 : 
		animation_controller.soft.play()
	
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
		
		
