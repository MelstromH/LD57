extends AnimatedSprite2D

var current_state : PlayerState.CharacterState

var locked = false

func _ready() :
	set_state(PlayerState.CharacterState.Standing)

func set_state(character_state) :
	
	if locked : return

	if character_state == current_state : 
		return
		
	#print(PlayerState.CharacterState.find_key(character_state))
		
	current_state = character_state
		
	match character_state : 
		PlayerState.CharacterState.Walking :
			play("walk")

		PlayerState.CharacterState.Running :
			play("run")

		PlayerState.CharacterState.Standing :
			play("default")
			
		PlayerState.CharacterState.LongJumpStarting : 
			play("longjumpstart")
			locked = true
		PlayerState.CharacterState.HardLanding : 
			play("hardfall")
			locked = true
		PlayerState.CharacterState.LethalLanding : 
			play("deadlyfall")
			locked = true
		PlayerState.CharacterState.Hopping : 
			play("hop")
			locked = true
		PlayerState.CharacterState.Mantling : 
			play("mantel")
			locked = true
		PlayerState.CharacterState.LongJumping : 
			play("jumploop")
		PlayerState.CharacterState.ClimbingUp : 
			play("walk")
		PlayerState.CharacterState.ClimbingDown : 
			play_backwards("walk")
		PlayerState.CharacterState.Crouching : 
			play_backwards("crouch")
		
func wait_for_animation() :
	
	while locked == true :
		await get_tree().create_timer(0.05).timeout
	
	return

func _on_animation_finished() -> void:
	locked = false
		
		


func _on_animation_looped() -> void:
	locked = false

		
