extends PlayerState
# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	if player.animation.current_animation != 'run':
		player.animation.play('run')

func physics_update(delta: float) -> void:
	# Horizontal movement.
	var input_direction_x: float = (
		Input.get_action_strength("right")
		- Input.get_action_strength("left")
	)
	player.velocity.x = player.speed_run * input_direction_x
	player.velocity.y += player.gravity * delta
	player.velocity = player.move_and_slide(player.velocity,  Vector2.UP)
	
	player.update_facing_dir()
	player.animation.advance(delta)
	if player.can_climb():
		state_machine.transition_to("Climb")
		return
		
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})
		return
		
	if is_equal_approx(player.velocity.x, 0.0):
		state_machine.transition_to("Idle")
		return
		
	if not player.is_on_floor():
		state_machine.transition_to("Air")
