class_name Crouching extends PlayerState
		
func get_name() -> String : return "Crouching"

func enter(player : PlayerBody) :
	player.animation_controller.set_state(PlayerState.CharacterState.Crouching)
	
func update(player : PlayerBody, delta: float) -> bool :
			
	if Input.is_action_just_pressed("Ladder") :
		player.ropes.add_rope_segments_at_end(5)
		#player.ropes.add_rope_segments(5)
		player.ropes.detach_base_node()
		
	if Input.is_action_just_pressed("Click") :
		var pos = player.ropes.end_node.global_position
		player.ropes.end_node.top_level = true
		player.ropes.end_node.position = pos
		player.ropes.end_node.freeze = false
		player.ropes.end_node.can_latch = true
		var mouse_pos = player.get_global_mouse_position()
		
		#player.ropes.add_rope_segments(15)
					
		player.ropes.end_node.linear_velocity = pos.direction_to(mouse_pos) * 600
		
	if not player.is_on_floor() :
		switch_state(player, PlayerState.longjumping_state)
		return false;
	elif player.state_container.on_ladder && Input.is_action_pressed("Climb") :
		switch_state(player, PlayerState.climbing_up_state) 
		return false;
		
	if Input.is_action_just_released("Down") :
		switch_state(player, PlayerState.standing_state)
		
	player.calculate_drag()
	
	return true;
