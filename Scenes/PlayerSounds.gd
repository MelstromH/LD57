extends Node

var footstep_interval = 100
var footstep_timer = 0

@onready var hard: AudioStreamPlayer = $"../Sounds/Hard"
@onready var soft: AudioStreamPlayer = $"../Sounds/Soft"
@onready var foot: AudioStreamPlayer = $"../Sounds/Foot"
@onready var lethal_sound : AudioStreamPlayer = $"../Sounds/Lethal"


func process_footsteps(timer_increment_value: int):
	if footstep_timer > footstep_interval : 
		var pitch = randf_range(0.85, 1.15)
		foot.pitch_scale = pitch
		foot.play()
		footstep_timer = 0
		
	footstep_timer += timer_increment_value
