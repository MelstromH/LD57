class_name PlayerState extends Object

static var standing_state = Standing.new()
static var running_state = Running.new()
static var walking_state = Walking.new()
static var mantling_state = Mantling.new()
static var longjumpstart_state = LongJumpStarting.new()
static var longjumping_state = LongJumping.new()
static var climbing_up_state = ClimbingUp.new()
static var climbing_down_state = ClimbingDown.new()

func switch_state(player : PlayerBody, state: PlayerState) : 
	
	if state == player.state :
		return;
	
	print(self.get_name() + " triggered: " + player.state.get_name() + " -> " + state.get_name())
	
	player.state.exit(player)
	player.state = state
	player.state.enter(player)

func update(player : PlayerBody, delta: float) -> bool : return true
func enter(player : PlayerBody) : pass
func exit(player : PlayerBody) : pass
func get_name() -> String : return "BaseState"

class Standing extends PlayerState :
		
	func get_name() -> String : return "Standing"
		
	func update(player : PlayerBody, delta: float) -> bool :

		if Input.is_action_just_pressed("Jump") :
			if player.can_mantle :
				switch_state(player, PlayerState.mantling_state)
				return false;
			else :
				switch_state(player, PlayerState.longjumpstart_state)
				return false;
			
		if not player.is_on_floor() :
			switch_state(player, PlayerState.longjumping_state)
			return false;
		elif player.state_container.on_ladder && Input.is_action_pressed("Climb") :
			switch_state(player, PlayerState.climbing_up_state) 
			return false;
		else :
			
			if player.velocity.x != 0:
				if abs(player.momentum) < (player.momentum_max * player.run_threshold) : 
					switch_state(player, PlayerState.walking_state)
				else : 
					switch_state(player, PlayerState.running_state)
			else : 
				player.animation_controller.set_state(PlayerState.CharacterState.Standing)
				
			var direction := Input.get_axis("Left", "Right")
			
			if direction && !player.animation_controller.locked :	
				player.momentum += (direction) * (player.acceleration)
			
			#calculate drag
			player.momentum = move_toward(player.momentum, 0, player.friction * abs(player.momentum/player.momentum_max) + player.friction)
				
			player.set_direction_facing(player.velocity.x)
			
			player.state_container.last_grounded_location = player.tile_map.map_to_local(player.tile_map.local_to_map(player.position))
		
		return true;
		#print("velocity: " + str(player.velocity.x))
class Walking extends Standing :
		
	func get_name() -> String : return "Walking"
	
	func update(player : PlayerBody, delta: float) -> bool :
		if !super(player, delta) : 
			return false
		
		if player.velocity.x == 0 :
			switch_state(player, PlayerState.standing_state)
		elif abs(player.momentum) > (player.momentum_max * player.run_threshold) :
			switch_state(player, PlayerState.running_state)
		else :
			player.animation_controller.set_state(PlayerState.CharacterState.Walking)
			player.sounds.process_footsteps(2)
			
		return true
		
class Running extends Standing :
		
	func get_name() -> String : return "Running"
	
	func update(player : PlayerBody, delta: float) -> bool :
		if !super(player, delta) : 
			return false
		
		if abs(player.momentum) < (player.momentum_max * player.run_threshold) :
			switch_state(player, PlayerState.standing_state)
		else :
			player.animation_controller.set_state(PlayerState.CharacterState.Running)
			player.sounds.process_footsteps(4)
		return true
		
class LongJumping extends PlayerState :
		
	func get_name() -> String : return "LongJumping"
	
	func update(player : PlayerBody, delta: float) -> bool :
		
		if player.is_on_floor() :
			switch_state(player, PlayerState.standing_state)
			return false
			
		if Input.is_action_just_pressed("Jump") && player.can_mantle:
			switch_state(player, PlayerState.mantling_state)
			
		if player.state_container.on_ladder && not Input.is_action_pressed("Climb"):
			switch_state(player, PlayerState.climbing_down_state) 
		elif player.state_container.on_ladder && Input.is_action_pressed("Climb") :
			switch_state(player, PlayerState.climbing_up_state)
		else :
			player.velocity += player.get_gravity() * delta * player.state_container.gravity_multiplier
			player.animation_controller.set_state(PlayerState.CharacterState.LongJumping) 
			
		var direction := Input.get_axis("Left", "Right")
			
		player.momentum += (direction) * (player.acceleration/2)
		#calculate drag
		player.momentum = move_toward(player.momentum, 0, player.friction + (player.friction/2 * abs(player.momentum)))	
		
		player.set_direction_facing(player.velocity.x)
		
		return true
		
class ClimbingUp extends PlayerState :
	func get_name() -> String : return "ClimbingUp"
	
	func update(player : PlayerBody, delta: float) -> bool :
		if !super(player, delta) : 
			return false
			
		if not Input.is_action_pressed("Climb") || not player.state_container.on_ladder :
			switch_state(player, PlayerState.standing_state)
	
		player.velocity.y = -50
		player.state_container.climbed = true	
		
		var direction := Input.get_axis("Left", "Right")
			
		player.momentum += (direction) * (player.acceleration)
		#calculate drag
		player.momentum = move_toward(player.momentum, 0, player.friction + (player.friction/2 * abs(player.momentum)))	
		
		player.set_direction_facing(player.velocity.x)
		
		player.animation_controller.set_state(PlayerState.CharacterState.ClimbingUp)
		
		return true
		
class ClimbingDown extends LongJumping :
	func get_name() -> String : return "ClimbingDown"
	
	func update(player : PlayerBody, delta: float) -> bool :
		if !super(player, delta) : 
			return false
		
		player.velocity.y = 50
		player.state_container.climbed = true
		player.animation_controller.set_state(PlayerState.CharacterState.ClimbingDown)
		
		return true
		
class Mantling extends PlayerState :
	
	func get_name() -> String : return "Mantling"
	
	func enter(player : PlayerBody) :
		
		player.momentum = 0
		player.animation_controller.set_state(PlayerState.CharacterState.Mantling)
		
		#camera control
		var camera_start = player.remote_transform_2d.global_position
		player.remote_transform_2d.top_level = true
		player.remote_transform_2d.position = camera_start
		
		#move player
		player.position = player.mantle_location.global_position
		
		player.remote_transform_2d.gradually_move_to_player(player)
		
		await player.animation_controller.wait_for_animation()
		
		switch_state(player, PlayerState.standing_state)
		

class LongJumpStarting extends PlayerState :
	
	func get_name() -> String : return "LongJumpStarting"
	
	func enter(player : PlayerBody) :
	
		player.actual_jump_velocity = player.BASE_JUMP_VELOCITY
		player.animation_controller.set_state(PlayerState.CharacterState.LongJumpStarting)
		var stored_momentum = player.momentum
		player.momentum = 0.5 * player.momentum
		await player.animation_controller.wait_for_animation()
		player.momentum = stored_momentum * 1.4
		player.velocity.y = player.actual_jump_velocity * 1.3
		
		switch_state(player, PlayerState.longjumping_state)
		

enum CharacterState {Standing = 1, Starting = 3, Walking = 4, Running = 5, Hopping = 6, Mantling = 7, LongJumpStarting = 8, HardLanding = 9, LethalLanding = 10, LongJumping = 11, ClimbingUp = 12, ClimbingDown = 13 }
