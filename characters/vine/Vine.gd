class_name Vine
extends Node2D
var PIECE = preload("res://characters/vine/VineSegment.tscn")

var growing: bool = true

export var max_length: float = 100
export var max_width: float = 10 
export var segment_max_length: float = 40 
export var segment_rotation: float = PI/8

var width = 1
	
func get_total_length() -> float:
	var seg = $Root
	var length = 0.0
	while seg:
		length += seg.length
		seg = seg.next_segment
	
	return length

func _ready():
	$Root.vine = self
	$Root.set_tip($Tip)
	
func _process(delta):		
	if growing:
		$Root.grow_length(delta)
		
	width = clamp(width+delta, 1, max_width)

func _on_Tip_body_entered(body):
	if body is TileMap:
		growing = false
