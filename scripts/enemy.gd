class_name Enemy extends Path2D

enum State {WAIT, PATROL, CHASE, ATTACK}
enum Direction { UP, UP_RIGHT, DOWN, DOWN_RIGHT }

@export var character: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var path_follow: PathFollow2D
@export var animation_player: AnimationPlayer
@export var roam_speed: float
@export var raycast: RayCast2D 
@export var line: Line2D #Just visual to keep track of raycast
@export var light_area: Area2D
@export var starting_ang: float = 0
@export var raycast_amt = 12
@export var player: CharacterBody2D
@export var state: State

@onready var raycast_arr: Array[RayCast2D] = [raycast]
@onready var raycast_ang: float = starting_ang
@onready var attack_timer = $PathFollow2D/AttackTimer

@onready var line_arr: Array[Line2D] = [line]
@onready var bullet = preload("res://scenes/bullet.tscn")
@onready var main = get_tree().get_root().get_node("main")

#Light is Area2D, darkness is revealed when light collides with it. 
var following_path: bool = true
var direction: String = "up"
var action: String = "walk"

func _ready() -> void:
	set_up_raycast()
	animation_player.play(action + "_" + direction)

func _physics_process(delta: float) -> void:
	if following_path and state == State.PATROL:
		var path_pos_before: Vector2 = path_follow.position
		path_follow.progress += roam_speed * delta
		set_dir(path_pos_before.angle_to_point(path_follow.position))
	for i in range(raycast_arr.size()):
		if raycast_arr[i].is_colliding():
			#print(i)
			sense()

func set_dir(angle: float) -> void:
	#print(rad_to_deg(angle))
	change_raycast_rotation(angle) #TEMP SOLUTION (WHEN 8 DIRECTION ADDED WILL CHANGE)
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
	for i in range(raycast_amt):
		raycast_ang -= 10
		duplicate_line()
		duplicate_raycast()
	change_raycast_rotation(deg_to_rad(starting_ang))
	#duplicate_raycast()

func duplicate_raycast():
	var new_raycast = raycast.duplicate()
	new_raycast.position = raycast.position
	character.add_child(new_raycast)
	raycast_arr.append(new_raycast)

func duplicate_line():
	var new_line = line.duplicate()
	new_line.position = line.position
	character.add_child(new_line)
	line_arr.append(new_line)

func change_raycast_rotation(angle: float):
	if state == State.PATROL:
		angle += deg_to_rad(-90)
	else:
		angle += deg_to_rad(90)
	var ori_angle = angle
	for i in range(raycast_arr.size()):
		raycast_arr[i].rotation = angle
		line_arr[i].rotation = angle
		if raycast_arr.size()/2 > i: #part 1
			angle += deg_to_rad(10)
		elif floor(raycast_arr.size()/2) == i: #part 2
			angle = ori_angle
			angle += deg_to_rad(-10)
		else: #part 3
			angle += deg_to_rad(-10)

#Check if player is in light or out of light after raycast senses them
func sense():
	if player.in_light_arr:
		state = State.CHASE
		#print(rad_to_deg(rotation + player.global_position.angle_to_point(path_follow.global_position)))
		change_raycast_rotation(player.global_position.angle_to_point(path_follow.global_position))
		if attack_timer.time_left == 0:
			attack_timer.start()

func attack():
	var new_bullet = bullet.instantiate()
	new_bullet.dir = player.global_position.angle_to_point(path_follow.global_position) + deg_to_rad(270)
	new_bullet.position = character.global_position
	new_bullet.rotation = player.global_position.angle_to_point(path_follow.global_position)
	new_bullet.visible = true
	new_bullet.z_index = 1
	add_child(new_bullet)

func _on_attack_timer_timeout():
	attack()
