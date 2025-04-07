extends AudioStreamPlayer

const LD_57_CAVE_AMBIENCE = preload("res://Sound/Music/LD57 Cave Ambience.wav")
const LD_57_REMIX = preload("res://Sound/Music/LD57 remix.wav")
const LD_57_SOUNDSCAPE = preload("res://Sound/Music/LD57 soundscape.wav")

var current_track
var tracks = [LD_57_CAVE_AMBIENCE, LD_57_REMIX, LD_57_SOUNDSCAPE]

@export var fade_to := 0
@export var fade_speed := 0.1

var fading := false

func choose_track():
	var track = tracks.pick_random()
	stream = track

func check_track_switch():
	var _pos = get_playback_position()
	var _length = stream.get_length()
	if _length - _pos < 1: #less than 1 second
		fading = true
		fade_to = -20

func fade():
	if fading:
		volume_db = move_toward(volume_db, fade_to, fade_speed)
		if volume_db == fade_to:
			fading = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stream = LD_57_CAVE_AMBIENCE
	await get_tree().create_timer(2).timeout
	volume_db = -20
	fading = true
	play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fade()
	check_track_switch()
	

func _on_finished() -> void:
	choose_track()
	fading = true
	fade_to = 0
	play()
