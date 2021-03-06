extends Node

onready var current_level = preload("res://Scripts/Levels/level1.gd").new()
onready var road_scene = preload("res://Scenes/Elements/road.tscn")
onready var rider_scene = preload("res://Scenes/rider.tscn")
onready var current_level_slopes = []

onready var global = get_node("/root/global")

export var scale = 100
export var offset_below_0 = 0.05
export var speed = 1.0

var riders = []
var roads = []

func _ready():
	global.level_generator = self
	
	var terrain_keys = current_level.terrain.keys()
	for x in range(terrain_keys.size() - 1):
		var km_start = terrain_keys[x]
		var km_end = terrain_keys[x + 1]
		var height = current_level.terrain[km_start]
		var height_next = current_level.terrain[km_end]
		var portion_length = km_end - km_start
		
		var slope_infos = {}
		slope_infos["slope"] = (height_next - height) / (km_end - km_start)
		slope_infos["start"] = km_start * scale
		slope_infos["end"] = km_end * scale
		slope_infos["height_start"] = height * scale
		slope_infos["distance"] = 0 #TODO: Angle computation etc
		slope_infos["gradient"] = slope_infos["slope"] * 100
		
		current_level_slopes.append(slope_infos)
		
		var road = road_scene.instance()
		add_child(road)

		road.position = Vector2(km_start * scale, offset_below_0 * scale)
		road.scale = Vector2(scale * portion_length, scale)
		road.set_color(get_slope_color(slope_infos["gradient"]))
		
		var polygon = road.polygon
		polygon.set(1, Vector2(0, -height - offset_below_0))
		polygon.set(2, Vector2(1, -height_next - offset_below_0))
		road.polygon = polygon
		
		roads.append(road)
	
	for i in range(3):
		var rider = rider_scene.instance()
		add_child(rider)
		
		rider.set_color(Color(1 if i == 0 else 0, 1 if i == 1 else 0, 1 if i == 2 else 0, 1))
		rider.mountain = 75
		rider.flat = 75
		rider.descent = 75
		
		if i == 0:
			rider.mountain = 80
		elif i == 1:
			rider.flat = 80
		elif i == 2:
			rider.descent = 80
		
		rider.position = Vector2(0, current_level.terrain[0])
		riders.append(rider)

	global.camera.follow(riders[0])

func _process(delta):
	if Input.is_action_pressed("speed_up"):
		speed *= 1.5
	elif Input.is_action_pressed("speed_down"):
		speed /= 1.5
		
	for rider in riders:
		rider.update_rider(delta * speed)
	
func get_slope_color(gradient):
	if gradient < 0:
		if gradient < -10:
			var value = 1.0 - gradient / -10.0
			return Color(value, 1, value, 1)
		else:
			gradient = min(-gradient, 25.0)
			return Color(0, 1.0 - (gradient - 10.0) / 15.0, 0, 1)
	else:
		if gradient < 4:
			return Color(1, 1, 1.0 - gradient / 4.0, 1)
		elif gradient < 10:
			return Color(1, 1.0 - (gradient - 4.0) / 6.0, 0, 1)
		else:
			gradient = min(gradient, 25.0)
			return Color(1.0 - (gradient - 10.0) / 15.0, 0, 0, 1)