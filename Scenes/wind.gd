extends Node

var timer : int = 0
@export var interval_max : int = 7000
@export var interval_min : int = 5000
@export var wind_effect : Node

var alarm_sound : AudioStreamPlayer
var wind_sound : AudioStreamPlayer
var player_state : Node

var interval : int

func _ready() :
	interval = randi_range(interval_min, interval_max)
	alarm_sound = $Alarm
	wind_sound = $WindSound
	player_state = get_node("%StateContainer")

func _process(float) : 
	
	if timer > interval :
		trigger_wind()
		timer = 0
		interval = randi_range(interval_min, interval_max)
		
	timer += 1
	
func trigger_wind() :
	
	alarm_sound.play()
	
	pass

func activate_wind() :
	wind_sound.play()
	player_state.gravity_multiplier = 0.5
	wind_effect.visible = true
	pass
	
func deactivate_wind() : 
	player_state.in_wind = false
	wind_effect.visible = false
	player_state.gravity_multiplier = 1
	pass
	
func _on_alarm_finished() -> void:
	player_state.in_wind = true
	activate_wind()

func _on_wind_sound_finished() -> void:
	deactivate_wind()
