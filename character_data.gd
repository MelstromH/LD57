extends Node2D

@export var max_health = 5
var current_health

var health_listeners : Array[Node]
	
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
