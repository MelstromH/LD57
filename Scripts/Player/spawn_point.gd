extends Node2D

@onready var ladder = $"Ladder"
@onready var player_state = get_node("%StateContainer")

var previous_frame_falling_speed = 0

var crumble_timer = 0
@export var crumble_threshold = 120

func _ready() -> void:
	top_level = true
	global_position = player_state.global_position

func move_spawn() : 	
	
	if player_state.number_scraps >= player_state.scrap_ladder_threshold:
		player_state.reset_scraps()
		global_position = player_state.global_position
		
	
