class_name Enemy extends Path2D

enum Direction { UP, UP_RIGHT, DOWN, DOWN_RIGHT }

@export var character: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var path_follow: PathFollow2D
@export var animation_player: AnimationPlayer
@export var roam_speed: float
@export var raycast: RayCast2D 
@export var line: Line2D #Just visual to keep track of raycast
@export var starting_ang = 60
@export var end_ang = -60

@onready var raycast_arr = [raycast]
@onready var angle = starting_ang

#Light is Area2D, darkness is revealed when light collides with it. 
var following_path: bool = true
var direction: String = "up"
var action: String = "walk"

func _ready() -> void:
	set_up_raycast()
	animation_player.play(action + "_" + direction)

func _physics_process(delta: float) -> void:
	if following_path:
		var path_pos_before: Vector2 = path_follow.position
		path_follow.progress += roam_speed * delta
		set_dir(path_pos_before.angle_to_point(path_follow.position))
	for i in range(raycast_arr.size()):
		if raycast_arr[i].is_colliding():
			print(i)

func set_dir(angle: float) -> void:
	var direction_before: String = direction
	angle = fmod(angle + TAU * 6, TAU) - PI
	direction = "down" if angle < 0.01 else "up"
	if abs(angle) < PI / 3.0:
		direction += "_left"
	elif abs(angle) > 2 * PI / 3.0:
		direction += "_right"
	
	if direction_before != direction:
		animation_player.play(action + "_" + direction)

func set_up_raycast():
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
	character.add_child(new_raycast)
	raycast_arr.append(new_raycast)

func duplicate_line():
	var new_line = line.duplicate()
	new_line.position = line.position
	new_line.rotation = deg_to_rad(angle)
	character.add_child(new_line)
