extends Camera2D


export var preserve_on_exit: bool = true
var has_started: bool = false
		
func get_temporary_children():
	var children: Array = []
	for c in get_children():
		if c.name != 'Area2d':
			children.push_back(c)
	return children


func reset_level(player: Player):
	get_tree().paused = true
	for c in get_temporary_children():
		if c is Vine:
			c.reset()
		if c is StartPlatform and player:
			player.reset_transform(c.global_transform)
		
	yield(get_tree(), "idle_frame")
	get_tree().paused = false
	has_started = preserve_on_exit
	current = true
		

func _on_Area2D_body_exited(body):
	if body.get_meta("type") == 'player':
		current = false

func _on_Area2D_body_entered(body):
	current=true
	if body is Player:
		reset_level(null)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current and Input.is_action_just_pressed("reset"):
		reset_level(get_parent().get_node('Player'))

