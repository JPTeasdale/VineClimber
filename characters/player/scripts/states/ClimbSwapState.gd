extends PlayerState
# Upon entering the state, we set the Player node's velocity to zero.
var swap_time = 0.2;
var target: Transform2D = Transform2D.IDENTITY
func enter(_msg := {}) -> void:
	target = _msg['transform']
	$SwapTimer.start(swap_time)
	
func process(delta: float) -> void:
	if $SwapTimer.is_stopped():
		player.global_transform = target
		state_machine.transition_to("Climb")
		return
		


	player.global_transform = player.global_transform.interpolate_with(target, 1-($SwapTimer.time_left/swap_time))
	
