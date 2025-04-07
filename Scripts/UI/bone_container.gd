extends Node2D

var state_container
var bones : Array[Node]

func _ready() :
	bones = get_children()
	state_container = get_node("%StateContainer")
	state_container.subscribe_bones(self)
	
func update_bones(current_bones : int) :
	for i in 3 :
		if i > current_bones - 1 :
			#hearts[i].set_texture(EMPTY_HEART)
			bones[i].visible = false
		else :
			#hearts[i].set_texture(FULL_HEART)
			bones[i].visible = true
