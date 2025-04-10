extends Node2D

@export var max_health = 5
var current_health

var health_listeners : Array[Node]
var bone_listeners : Array[Node]

var in_wind : bool = false
var in_shelter : bool = false
var rad_timer : int = 0
var rad_threshold : int = 240

@onready var spawn_point: Node2D = $"../SpawnPoint"

var on_ladder = false
var climbed = false

var gravity_multiplier = 1

@export var default_scraps = 0
var number_scraps = 0
@export var scrap_ladder_threshold = 3
var last_grounded_location : Vector2
var bone_pile_scene : PackedScene

@onready var get_bone: AudioStreamPlayer = $"../Sounds/GetBone"

var grace_period = false
	
func subscribe_health(listener: Node) :
	health_listeners.append(listener)

func subscribe_bones(listener: Node) :
	bone_listeners.append(listener)

func add_scrap(amount : int) :
	number_scraps += amount
	number_scraps = clamp(number_scraps, 0,3)	
	update_bone_listeners()

func reset_scraps() :
	number_scraps = 0
	update_bone_listeners()
	
func _ready() :
	bone_pile_scene = load("res://Scenes/skeleton.tscn")
	current_health = max_health
	number_scraps = default_scraps
	for listener in health_listeners :
		listener.update_health(current_health)
		
	for listener in bone_listeners :
		listener.update_bones(number_scraps)
	
func reset() :
	
	print("RESET")
	
	get_parent().position = spawn_point.global_position
	var bone_instance = bone_pile_scene.instantiate()
	add_child(bone_instance)
	bone_instance.player_state = self
	bone_instance.position = last_grounded_location
	bone_instance.top_level = true
	
	
	current_health = max_health
	number_scraps = default_scraps
	
	for listener in health_listeners :
		listener.update_health(current_health)
	await get_tree().create_timer(1).timeout
	
	update_bone_listeners()

	grace_period = false
	
	
func damage(dmg : int) :
	if grace_period : 
		for listener in health_listeners :
			listener.update_health(current_health)
		return
	
	print("damage: " + str(dmg) + " health: " + str(current_health))
	current_health -= dmg
	
	for listener in health_listeners :
		listener.update_health(current_health)
		
	if current_health <= 0 :
		reset()
		grace_period = true
		
func _process(delta: float) -> void:
	
	handle_radiation()
	
func update_bone_listeners() :
	get_bone.play()
	
	for listener in bone_listeners :
		listener.update_bones(number_scraps)
	
func handle_radiation() :
	if in_wind && not in_shelter :
		rad_timer += 1
	
	if rad_timer > rad_threshold:
		rad_timer = 0
		damage(1)
	
	if in_shelter || not in_wind : 
		rad_timer = 0


func _on_shelter_detector_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	in_shelter = true
	
	print("shelter")
	pass # Replace with function body.


func _on_shelter_detector_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("no shelter") 
	in_shelter = false
	
	pass # Replace with function body.
