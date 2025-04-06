extends AnimatedSprite2D

var current_state : PlayerState.CharacterState = PlayerState.CharacterState.Standing

func _ready() :
	set_state(PlayerState.CharacterState.Standing)

func set_state(character_state) :
	if character_state == current_state : 
		return
		
	current_state = character_state
		
	match character_state : 
		PlayerState.CharacterState.Walking :
			play("walk")
		PlayerState.CharacterState.Running :
			play("run")
		PlayerState.CharacterState.Standing :
			play("default")
		PlayerState.CharacterState.Jumping : 
			play("run")
			set_frame_and_progress(5, 0)
		
			
