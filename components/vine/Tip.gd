class_name VineTip
extends Area2D

var vine = null

# Called when the node enters the scene tree for the first time.
func _process(delta):
	if vine and vine.locked:
		update()
		
func _draw():
	if vine and vine.locked:
		draw_circle(position, 3, vine.color)
