extends PlayerState
# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	# We must declare all the properties we access through `owner` in the `Player.gd` script.
	player.velocity = Vector2.ZERO
	player.animation.play('idle')

func process(delta: float) -> void:
	# If you have platforms that break when standing on them, you need that check for 
	# the character to fall.
		
	player.animation.advance(delta)
	if not owner.is_on_floor():
		state_machine.transition_to("Air")
		return
		
	if Input.is_action_just_pressed("jump"):
		# As we'll only have one air state for both jump and fall, we use the `msg` dictionary 
		# to tell the next state that we want to jump.
		state_machine.transition_to("Air", {do_jump = true})
		return
	elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		state_machine.transition_to("Run")
		return

