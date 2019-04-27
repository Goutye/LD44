extends Node2D

onready var global = get_node("/root/global")

export var speed = 100.0

var current_slope_id = 0

func _ready():
	pass

func _process(delta):
	var slope_infos = global.level_generator.current_level_slopes[current_slope_id]
	
	var new_position = Vector2(0,0)
	
	new_position.x = position.x + gradient_to_speed(slope_infos["gradient"]) * delta
	new_position.y = (new_position.x - slope_infos["start"]) * slope_infos["slope"] + slope_infos["height_start"]
	
	new_position.y = -new_position.y
	position = new_position
	
	if position.x >= slope_infos["end"]:
		print("new slope")
		current_slope_id += 1
		
		if global.level_generator.current_level_slopes.size() == current_slope_id:
			current_slope_id = 0
			position.x = 0
	
func gradient_to_speed(gradient):
	if gradient < 0:
		gradient = max(gradient, -7)
		return speed * (1 + gradient / -7);
	elif gradient < 10:
		return speed / (1 + gradient / 10.0)
	elif gradient < 20:
		return speed / (2 + gradient / (10/2) )
	else:
		gradient = min(30, gradient)
		return speed / (4 + gradient / (10/4) )