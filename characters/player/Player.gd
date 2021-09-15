class_name Player
extends KinematicBody2D

var speed_run = 100
var speed_climb = 25
var impulse_jump = 200
var gravity = 500

onready var animation := $AnimationPlayer as AnimationPlayer

var velocity = Vector2()
onready var hand: Position2D = $Hand
onready var foot: Position2D = $Foot
onready var foot_ray: RayCast2D = $FootRay

func can_climb() -> bool:
	return $HandRay1.is_colliding() && $FootRay.is_colliding()
	
func get_facing_dir() -> float:
	return sign(scale.y)

func flip_facing_dir():
	apply_scale(Vector2(-1, 1))
	
func get_vine_collision_normal() -> Vector2:
	return (($HandRay1.get_collision_normal() + 
		$HandRay2.get_collision_normal() + 
		$HandRay3.get_collision_normal()) + 
		$FootRay.get_collision_normal()).normalized()
		
func get_hand_collision_point() -> Vector2:
	return $HandRay1.get_collision_point() 
	
func get_hand_collider() -> Node2D:
	return $HandRay1.get_collider() 
	
func update_facing_dir():
	var input_direction_x: float = (
		Input.get_action_strength("right") 
		- Input.get_action_strength("left")
	)	
	
	if sign(input_direction_x) && input_direction_x != get_facing_dir():
		flip_facing_dir()
	
		
