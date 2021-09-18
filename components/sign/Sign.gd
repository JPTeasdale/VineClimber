extends Node2D

export var hint_texture: Texture setget set_hint

func set_hint(t: Texture):
	$Hint.texture = t

func _on_Area2D_body_entered(body):
	$AnimationTree.set("parameters/show/active", true)


func _on_Area2D_body_exited(body):
	$AnimationTree.set("parameters/hide/active", true)
