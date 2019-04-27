extends Polygon2D

onready var global = get_node("/root/global")

export var rider_base_speed = 40.0
export var flat = 50
export var mountain = 50
export var descent = 50

var current_slope_id = 0
var time = 0

func _ready():
	pass

func update_rider(delta):
	time += delta
	
	var slope_infos = global.level_generator.current_level_slopes[current_slope_id]
	
	var new_position = Vector2(0,0)
	
	var speed = gradient_to_speed(slope_infos["gradient"])
	new_position.x = position.x + speed * delta
	if new_position.x > slope_infos["end"]:
		current_slope_id += 1
		if global.level_generator.current_level_slopes.size() == current_slope_id:
			current_slope_id = 0
			position.x = 0
		
		slope_infos = global.level_generator.current_level_slopes[current_slope_id]
		
		var difference = new_position.x - slope_infos["start"]
		var distance_done = new_position.x - position.x
		var remaining_delta = difference / distance_done * delta
		
		new_position.x = slope_infos["start"] + gradient_to_speed(slope_infos["gradient"]) * remaining_delta
		
		print(get_color(), " ", time - remaining_delta)
		
	new_position.y = (new_position.x - slope_infos["start"]) * slope_infos["slope"] + slope_infos["height_start"]
	
	new_position.y = -new_position.y
	position = new_position
	
func gradient_to_speed(gradient):
	var speed = rider_base_speed * get_speed_multiplier(gradient)
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
		
func get_speed_multiplier(gradient):
	var attribute = 0
	if gradient < -3:
		attribute = descent
	elif gradient <= 3:
		attribute = flat
	else:
		attribute = mountain

	var ratio = clamp(attribute, 0, 100) / 100.0
	return ratio  * 0.8 + 0.4