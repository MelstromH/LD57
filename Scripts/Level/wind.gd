extends Node

var timer : int = 0
@export var interval_max : int
@export var interval_min : int
@export var wind_effect : Node

var alarm_sound : AudioStreamPlayer
var wind_sound : AudioStreamPlayer

var interval : int

func _ready() :
	interval = randi_range(interval_min, interval_max)
	alarm_sound = $Alarm
	wind_sound = $WindSound

func _process(float) : 
	
	if timer > interval :
		trigger_wind()
		timer = 0
		interval = randi_range(interval_min, interval_max)
		
	if !wind_sound.playing && !alarm_sound.playing :
		timer += 1
	
func trigger_wind() :
	
	alarm_sound.play()
	
	pass

func activate_wind() :
	SignalHub.wind_activated.emit()
	
	wind_sound.play()

	wind_effect.visible = true
	pass
	
func deactivate_wind() : 
	SignalHub.wind_deactivated.emit()

	wind_effect.visible = false

	pass
	
func _on_alarm_finished() -> void:
	activate_wind()

func _on_wind_sound_finished() -> void:
	deactivate_wind()
