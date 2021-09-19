class_name Vine
extends Node2D
var PIECE = preload("res://components/vine/VineSegment.tscn")

signal vine_locked

var growing: bool = false
var locked: bool = false
var dead: bool = false

export var life_duration_s: float = 10
export var max_length: float = 100
export var max_width: float = 10 
export var segment_rotation: float = PI/16
var segment_max_length: float = 10

var color: Color = Color("#09902b")

var width = 1
var segments: Array = []

var SEGMENT = preload("res://components/vine/VineSegment.tscn")
var TIP = preload("res://components/vine/VineTip.tscn")

func get_root():
	return $Anchor/PinJoint2D.get_node("Root")

func reset():
	if $Anchor/PinJoint2D.has_node("Root"):
		var root = get_root()
		root.clear()
		$Anchor/PinJoint2D.remove_child(root)
	
	segments = []
	width = 1
	growing = true
	locked = false
	dead = false
	var tip = TIP.instance()
	var root = SEGMENT.instance()
	tip.connect("body_entered", self, "_on_Tip_body_entered")
	
	tip.vine = self
	tip.name = "Tip"
	add_child(tip)
	root.vine = self
	root.name = "Root"
	root.mode = RigidBody2D.MODE_STATIC
	$Anchor/PinJoint2D.add_child(root)
	root.set_tip(tip)
	$Anchor/PinJoint2D.disable_collision = false
	$Anchor/PinJoint2D.node_b = root.get_path()
	$Anchor/PinJoint2D.disable_collision = true
	$Life.start(life_duration_s)
	segments.push_back(root)
	
	
func get_total_length() -> float:
	return (segment_max_length * (segments.size() - 1)) + segments.back().length

func _ready():
	reset()
	
func _physics_process(delta):
	if not locked and $Life.is_stopped():
		if not dead:
			dead = true
			growing = false
			get_root().die()
		return
			
		
	if growing:
		var grow_speed = max_length / (life_duration_s * 100)
		var percent_complete = 1 - ($Life.time_left / life_duration_s)
		get_root().grow_length(grow_speed)
		
		if percent_complete < 0.8:
			color = lerp(Color("#09902b"), Color.olive, percent_complete * 1.25)
		else:
			color = lerp(Color.olive, Color('#362419'), (percent_complete - 0.8) * 5)
		
	
	width = clamp(width+delta, 1, max_width)

func _on_Tip_body_entered(body):
	if body is TileMap:
		growing = false
		locked = true
		emit_signal("vine_locked")
