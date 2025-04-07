extends Node2D

var state_container
var hearts : Array[Node]

const BRITTLE_HEART = preload("res://Sprites/UI/Brittle_Heart.png")
const EMPTY_HEART = preload("res://Sprites/UI/Empty_Heart.png")
const FULL_HEART = preload("res://Sprites/UI/Full_Heart.png")

func _ready() :
	hearts = get_children()
	state_container = get_node("%StateContainer")
	state_container.subscribe_health(self)
	
func update_health(current_health : int) :
	for i in 5 :
		if i > current_health - 1 :
			hearts[i].set_texture(EMPTY_HEART)
			#hearts[i].visible = false
		else :
			hearts[i].set_texture(FULL_HEART)
			#hearts[i].visible = true
