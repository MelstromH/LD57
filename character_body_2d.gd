extends CharacterBody2D

enum CharacterState {Standing, Stopping, Starting, Walking, Running, Jumping}
var character_state = CharacterState.Standing

@export var SPEED = 25 
@export var JUMP_VELOCITY = -25

@export var momentum_max : float = 2.5
var momentum = 0;
@export var momentum_decay : float = 0.1
@export var momentum_damping : float = 5

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if  abs(momentum) >= (momentum_max * 0.8) : 
			velocity.y = JUMP_VELOCITY * 1.3
		else :
			velocity.y = JUMP_VELOCITY
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
			momentum = move_toward(momentum, 0, 0.1)
			character_state = CharacterState.Stopping
		
		momentum = clamp(momentum, -2.5, 2.5)
		
	else:
		momentum = move_toward(momentum, 0, 0.1)
		
		if momentum == 0 :
			character_state = CharacterState.Standing
		else :
			character_state = CharacterState.Stopping
			
	velocity.x = (SPEED * momentum) 
	move_and_slide()

#TODO
#- Mantling
#- Fall Damage
