extends AnimatedSprite2D

var current_state : PlayerState.CharacterState

var locked = false
var lethal_sound : AudioStreamPlayer

var footstep_interval = 100
var footstep_timer = 0

@onready var hard: AudioStreamPlayer = $"../Sounds/Hard"
@onready var soft: AudioStreamPlayer = $"../Sounds/Soft"
@onready var foot: AudioStreamPlayer = $"../Sounds/Foot"


func _ready() :
	set_state(PlayerState.CharacterState.Standing)
	lethal_sound = $"../Sounds/Lethal"
	
func _process(delta: float) -> void:
	
	if footstep_timer > footstep_interval && (current_state == PlayerState.CharacterState.Walking || current_state == PlayerState.CharacterState.Running) : 
		var pitch = randf_range(0.85, 1.15)
		foot.pitch_scale = pitch
		foot.play()
		footstep_timer = 0
		
	footstep_timer += 1

func set_state(character_state) :
	
	if locked : return

	if character_state == current_state : 
		return
		
	print(PlayerState.CharacterState.find_key(character_state))
		
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
		PlayerState.CharacterState.ClimbingUp : 
			play("ladder")
		PlayerState.CharacterState.ClimbingDown : 
			play_backwards("ladder")
		
func wait_for_animation() :
	
	while locked == true :
		await get_tree().create_timer(0.05).timeout
		
	
	return

func _on_animation_finished() -> void:
	locked = false
		
		


func _on_animation_looped() -> void:
	locked = false

		
