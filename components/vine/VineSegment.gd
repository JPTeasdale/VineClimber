class_name VineSegment
extends RigidBody2D

var SEGMENT = load("res://components/vine/VineSegment.tscn")

export var length: float = 0 setget set_length

var dead = false
var vine = null

var points: PoolVector2Array = PoolVector2Array()
var prev_segment = null 
var next_segment = null setget set_next_segment

func set_tip(tip: VineTip):
	tip.get_parent().remove_child(tip)
	$Anchor.add_child(tip)
	
func clear():
	if next_segment:
		next_segment.clear()
	queue_free()
	
func die():
	if dead:
		return
	dead = true
	mode = MODE_RIGID
	collision_layer = 0b10000000000000000000
	collision_mask = 0b00000000000000000010
	$Anchor.softness = .5

	if next_segment:
		next_segment.die()

func _ready():
	mode = MODE_STATIC
	set_meta('type','vine')

func grow_length(growth: float):
	if not vine.growing:
		return
		
	if next_segment:
		next_segment.grow_length(growth)
		return
		
	var next_length = length + growth
	set_length(next_length)
		
	if next_length >= vine.segment_max_length:
		var newSegment: VineSegment = SEGMENT.instance()
		newSegment.vine = vine
		newSegment.length = 0
		newSegment.rotation = vine.segment_rotation
		set_next_segment(newSegment)
		
func set_next_segment(seg: VineSegment):
	seg.prev_segment = self
	seg.set_tip(get_node("Anchor/Tip"))
	$Anchor.add_child(seg)
	$Anchor.node_b = seg.get_path()
	next_segment = seg
	
func get_length_to_start()-> float: 
	var s: VineSegment = prev_segment
	var length = 0
	while s: 
		length += s.length
		s = s.prev_segment
	return length

func set_length(l: float):
	length = l
	recompute_points()
	
func get_start_width() -> float:
	return (1 -(get_length_to_start() / vine.get_total_length())) * vine.width

func get_end_width() -> float:
	return max(2, (1-((get_length_to_start() + length) / vine.get_total_length())) * vine.width)

func recompute_points():
	var new_points: PoolVector2Array = PoolVector2Array()
	var start_width = get_start_width() / 2
	var end_width = get_end_width() / 2
	
	if !prev_segment:
		var bottom_right = Vector2.RIGHT.rotated(-rotation) * start_width
		new_points.append(bottom_right)
		var bottom_left = Vector2.LEFT.rotated(-rotation) * start_width
		new_points.append(bottom_left)
	else:
		var bottom_right = Vector2.RIGHT.rotated(-rotation/2) * start_width
		new_points.append(bottom_right)
		var bottom_left = Vector2.LEFT.rotated(-rotation/2) * start_width
		new_points.append(bottom_left)
	
	if !next_segment:
		new_points.append(Vector2(-end_width, -length))
		new_points.append(Vector2(end_width, -length))
	else:
		var top_left = Vector2(0, -length) + Vector2.LEFT.rotated(next_segment.rotation/2) * end_width 
		new_points.append(Vector2(top_left))		
		var top_right = Vector2(0, -length) + Vector2.RIGHT.rotated(next_segment.rotation/2) * end_width
		new_points.append(top_right)
		
	
	points = new_points

func pull(normal: Vector2):
	
	var dot = normal.dot(global_transform.x)
	var angle = normal.angle_to(global_transform.x)
	
	print("dot: ", dot)
	print("angle: ", angle)
	if vine.growing:
		var dir = sign(dot)
		rotation = lerp_angle(rotation,  dir*(vine.segment_rotation+PI/4), .001 * (vine.max_width - get_start_width()))
	
func _draw():
	if points.size() > 0:
		draw_circle(Vector2.ZERO, get_start_width() / 2, vine.color)
		draw_circle(Vector2(0, -length), get_end_width() / 2, vine.color)
		draw_polygon(points, PoolColorArray([vine.color]))	
	
func _process(delta):
	if not vine.dead:
		$Anchor.position = Vector2(0, -length)
		recompute_points()
	
	$Line.polygon = points
	update()
