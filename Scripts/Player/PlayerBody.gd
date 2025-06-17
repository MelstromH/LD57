class_name PlayerBody extends CharacterBody2D
#animation
@onready var animation_controller = $AnimatedSprite2D

@onready var state : PlayerState = PlayerState.Standing.new()

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
@export var friction : float = 0.1
@export var acceleration : float = 0.05
@export var run_threshold : float = 0.9

#other nodes
@export var tile_map : TileMapLayer
@onready var state_container = $StateContainer
@onready var ladder_spawn = $"LadderSpawn"
@onready var mantle_location = $"MantleTeleportLocation"
@onready var remote_transform_2d: RemoteTransform2D = $RemoteTransform2D
@onready var spawn_point: Node2D = $SpawnPoint
@onready var sounds: Node = $Sounds
@onready var ropes: Rope = $Ropes

func _ready() -> void: 
	ropes.end_node.latch_signal.connect(on_grapple_latched)

func _physics_process(delta: float) -> void:
	state.update(self, delta)
	
	detect_fall_damage()
	velocity.x = (SPEED * momentum) 
	move_and_slide()
	
	#if Input.is_action_just_released("Ladder") : 
		#ladder_spawn.handle_ladder()
		
	if Input.is_action_just_released("Checkpoint") : 
		spawn_point.move_spawn()
		

func handle_jump() :

		var stored_momentum = momentum
		momentum = 0
		animation_controller.set_state(PlayerState.CharacterState.Hopping)
		await animation_controller.wait_for_animation()
		if velocity != null && actual_jump_velocity:
			momentum = stored_momentum
			velocity.y = actual_jump_velocity * 1.
		
	
func set_direction_facing(direction_input: int) :
	if direction_input && direction_facing * direction_input <= 0 && !animation_controller.locked :
		scale.x = -1
		direction_facing = direction_input
		
func detect_fall_damage() :
	if animation_controller.current_state == PlayerState.CharacterState.Mantling:
		previous_frame_falling_speed = 0
		return
		
	
	if velocity.y - previous_frame_falling_speed < -180 && previous_frame_falling_speed > 0 :
		var damage : int = previous_frame_falling_speed / 180
		
		momentum = 0
		
		if  damage >= state_container.current_health : 
			animation_controller.set_state(PlayerState.CharacterState.LethalLanding)
			sounds.lethal_sound.play()
			await animation_controller.wait_for_animation()
			state_container.damage(damage)
		else : 
			state_container.damage(damage)
			sounds.hard.play()
			animation_controller.set_state(PlayerState.CharacterState.HardLanding)
	elif velocity.y - previous_frame_falling_speed < -70 && previous_frame_falling_speed > 0 : 
		sounds.soft.play()
		pass
	
	previous_frame_falling_speed = velocity.y
	
	if velocity.y > 800 : 
		momentum = 0
		velocity.y = 0
		previous_frame_falling_speed = 0
		state_container.last_grounded_location = Vector2(1000, 1000)
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

func on_grapple_latched() :
	state.switch_state(self, PlayerState.rope_swinging_state)
