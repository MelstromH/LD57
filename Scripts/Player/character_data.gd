extends Node2D

@export var max_health = 5
var current_health

var health_listeners : Array[Node]

var in_wind : bool = false
var in_shelter : bool = false
var rad_timer : int = 0
var rad_threshold : int = 240
	
func subscribe_health(listener: Node) :
	health_listeners.append(listener)

func _ready() :
	current_health = max_health
	
func damage(dmg : int) :
	current_health -= dmg
	
	for listener in health_listeners :
		listener.update_health(current_health)
		
	if current_health <= 0 :
		get_tree().reload_current_scene()
		
func _process(delta: float) -> void:
	
	handle_radiation()
	
	
func handle_radiation() :
	if in_wind && not in_shelter :
		rad_timer += 1
	
	if rad_timer > rad_threshold:
		rad_timer = 0
		damage(1)
	
	if in_shelter || not in_wind : 
		rad_timer = 0
