extends PlayerState
# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	player.animation.play('climb')
	player.animation.advance(0)
	$Cooldown.start(0.2)
	
func is_on_vine(): 
	var foot = player.foot_ray.get_collider()
	var hand = player.get_hand_collider()
	
	return foot && hand && foot.get_meta('type') == "vine" && hand.get_meta('type') == 'vine'

func get_collision_normal():
	var normal = player.get_vine_collision_normal()
	if not normal:
		return player.foot_ray.get_collision_normal()
	return normal
	
func get_facing_vector() -> Vector2:
	return (-get_collision_normal()).normalized()

func get_swap_transform():
	var facing_dir: Vector2 = get_facing_vector()
	for d in range(40):
		var test_transform: Transform2D = player.global_transform.orthonormalized()
		test_transform = test_transform.rotated(-test_transform.get_rotation())
		test_transform = test_transform.scaled(Vector2(-1, 1))
		test_transform = test_transform.rotated(player.rotation)

		var test_move = facing_dir * (d + 18)
		test_transform.origin = player.global_position + test_move

		if not player.test_move(test_transform, Vector2.ZERO):
			return test_transform
	return null
	
func physics_update(delta: float) -> void:
	# Horizontal movement.
	var input_direction_y: float = (
		Input.get_action_strength("down")
		- Input.get_action_strength("up")
	)
	
	if abs(input_direction_y) > 0:
		player.animation.advance(delta)
			
	var input_direction_x: float = 0
	if $Cooldown.is_stopped():
		input_direction_x = (
			Input.get_action_strength("right") 
			- Input.get_action_strength("left")
		)
	
	var normal = get_collision_normal()
	if not normal:
		state_machine.transition_to("Air")
		
	player.look_at(player.position - normal)
	player.move_and_collide(player.get_hand_collision_point() - player.hand.global_position)
	player.velocity = player.speed_climb * input_direction_y * player.get_facing_dir() * normal.tangent()
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)
	
	if is_on_vine():
		player.get_hand_collider().pull(get_collision_normal())
	
	if sign(input_direction_x):
		if sign(input_direction_x) != player.get_facing_dir():
			player.look_at(player.position + Vector2(player.get_facing_dir(), 0))
			state_machine.transition_to("Air", {do_jump= true})
			player.flip_facing_dir()
			return
		elif is_on_vine() && $Cooldown.is_stopped():
			var st = get_swap_transform()
			if st:
				state_machine.transition_to("ClimbSwap", {transform = st})
				return
	
	if not player.can_climb():
		player.look_at(player.position + Vector2(player.get_facing_dir(), 0))
		var msg = {}
		if player.velocity.y < 0 && player.foot_ray.is_colliding():
			msg.do_jump = true
		state_machine.transition_to("Air", msg)
		
	
