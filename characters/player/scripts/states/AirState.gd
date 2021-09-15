extends PlayerState
# Upon entering the state, we set the Player node's velocity to zero.
func enter(msg := {}) -> void:
	if player.animation.current_animation != 'run':
		player.animation.play('run')
	player.animation.advance(0)
	if msg.has("do_jump"):
		player.velocity.y = -player.impulse_jump

func physics_update(delta: float) -> void:
	# Horizontal movement.
	var input_direction_x: float = (
		Input.get_action_strength("right")
		- Input.get_action_strength("left")
	)
	player.velocity.x = player.speed_run * input_direction_x
	# Vertical movement.
	player.velocity.y += player.gravity * delta
	player.velocity = player.move_and_slide(player.velocity,  Vector2.UP)

	player.update_facing_dir()
	player.animation.advance(delta)
	if player.can_climb():
		state_machine.transition_to("Climb")
		return
	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")
