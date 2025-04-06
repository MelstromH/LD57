extends Node2D

var state_container
var hearts : Array[Node]

func _ready() :
	hearts = get_children()
	state_container = get_node("%StateContainer")
	state_container.subscribe_health(self)
	
func update_health(current_health : int) :
	for i in 5 :
		if i > current_health - 1 :
			hearts[i].visible = false
		else :
			hearts[i].visible = true
