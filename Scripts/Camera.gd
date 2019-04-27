extends Camera2D

var follower = null

onready var global = get_node("/root/global")

func _ready():
	global.camera = self

func _process(delta):
	if follower != null:
		position = follower.position

func follow(object):
	follower = object