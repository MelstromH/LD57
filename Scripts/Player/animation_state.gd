extends AnimatedSprite2D

var current_state : PlayerState.CharacterState = PlayerState.CharacterState.Standing

var locked = false
var lethal_sound : AudioStreamPlayer

@onready var hard: AudioStreamPlayer = $"../Sounds/Hard"
@onready var soft: AudioStreamPlayer = $"../Sounds/Soft"

func _ready() :
	play("default")
	current_state = PlayerState.CharacterState.Standing
	lethal_sound = $"../Sounds/Lethal"

func set_state(character_state) :
	
	if locked : return
	
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
		PlayerState.CharacterState.LongJumpStarting : 
			play("longjumpstart")
			locked = true
		PlayerState.CharacterState.HardLanding : 
			play("hardfall")
			hard.play()
			locked = true
		PlayerState.CharacterState.LethalLanding : 
			play("deadlyfall")
			lethal_sound.play()
			locked = true
		PlayerState.CharacterState.Hopping : 
			play("hop")
			locked = true
		PlayerState.CharacterState.Mantling : 
			play("mantel")
			locked = true
		PlayerState.CharacterState.LongJumping : 
			play("jumploop")
		
func wait_for_animation() :
	
	while locked == true :
		await get_tree().create_timer(0.05).timeout
		
	
	return

func _on_animation_finished() -> void:
	locked = false
		
		


func _on_animation_looped() -> void:
	locked = false

		
