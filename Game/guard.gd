extends CharacterBody2D

@export var starting_ang = 60
@export var end_ang = -60

@onready var raycast = $RayCast2D
@onready var line = $Line2D
@onready var raycast_arr = [raycast]
@onready var angle = starting_ang

#Light is Area2D, darkness is revealed when light collides with it. 

func _ready():
	set_up()

func _physics_process(delta):
	for i in range(raycast_arr.size()):
		if raycast_arr[i].is_colliding():
			print(i)

func set_up():
	raycast.rotation = deg_to_rad(starting_ang)
	line.rotation = deg_to_rad(starting_ang)
	while angle > end_ang:
		angle -= 10
		duplicate_line()
		duplicate_raycast()
	#duplicate_raycast()

func duplicate_raycast():
	var new_raycast = raycast.duplicate()
	new_raycast.position = raycast.position
	new_raycast.rotation = deg_to_rad(angle)
	add_child(new_raycast)
	raycast_arr.append(new_raycast)

func duplicate_line():
	var new_line = line.duplicate()
	new_line.position = line.position
	new_line.rotation = deg_to_rad(angle)
	add_child(new_line)
