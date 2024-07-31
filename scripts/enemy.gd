class_name Enemy extends Path2D

enum State {WAIT, PATROL, CHASE, FIND, ATTACK}
enum Direction { UP, UP_RIGHT, DOWN, DOWN_RIGHT }

@export var character: CharacterBody2D
@export var sprite: Sprite2D
@export var path_follow: PathFollow2D
@export var animation_player: AnimationPlayer
@export var roam_speed: float
@export var chase_speed: float
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
@onready var nav = $PathFollow2D/CharacterBody2D/NavigationAgent2D
@onready var chase_timer = $ChaseTimer
@onready var wait_timer = $WaitTimer

@onready var line_arr: Array[Line2D] = [line]
@onready var bullet = preload("res://scenes/bullet.tscn")
@onready var main = get_tree().get_root().get_node("main")

#Light is Area2D, darkness is revealed when light collides with it. 
var following_path: bool = true
var direction: String = "u"
var action: String = "e1_iw"

func _ready() -> void:
	set_up_raycast()
	animation_player.play(action + "_" + direction)

func _physics_process(delta: float) -> void:
	for i in range(raycast_arr.size()):
		if raycast_arr[i].get_collider() == player:
			sense()
	match state:
		State.WAIT:
			pass
		State.PATROL:
			if following_path:
				var path_pos_before: Vector2 = path_follow.position
				path_follow.progress += roam_speed * delta
				set_dir(path_pos_before.angle_to_point(path_follow.position))
		State.CHASE:
			var curr_agent_pos = character.global_position
			var next_path_pos = nav.get_next_path_position()
			character.velocity = curr_agent_pos.direction_to(next_path_pos) * chase_speed
			character.move_and_slide()
			set_dir(character.global_position.angle_to_point(player.position))
			start_attack()
			if light_area in player.in_light_arr:
				change_state(State.ATTACK)
				print('a')
		State.FIND:
			var curr_agent_pos = character.global_position
			var next_path_pos = nav.get_next_path_position()
			character.velocity = curr_agent_pos.direction_to(next_path_pos) * chase_speed
			character.move_and_slide()
			#print("find")
			if character.global_position == nav.target_position:
				if wait_timer.time_left == 0:
					wait_timer.start()
		State.ATTACK:
			set_dir(character.global_position.angle_to_point(player.position))
			start_attack()
			character.velocity = Vector2(0, 0)

func start_attack():
	if attack_timer.is_paused():
		attack_timer.set_paused(false)
	if attack_timer.time_left == 0:
		attack_timer.start()

func change_state(new_state):
	if new_state == state:
		return
	if (state == State.CHASE or state == State.ATTACK) and (new_state != State.CHASE or new_state != State.ATTACK):
		var pos = player.position
		nav.target_position = pos
		set_dir(character.global_position.angle_to_point(player.position))
		new_state = State.FIND
	if state == State.ATTACK or state == State.CHASE:
		attack_timer.stop()
	if new_state == State.PATROL and !curve:
		new_state = State.WAIT
		#print(new_state)
	if new_state != State.CHASE:
		chase_timer.stop()
	state = new_state

#Check if player is in light or out of light after raycast senses them
func sense():
	if player.in_light_arr and (state == State.PATROL or state == State.WAIT or state == State.FIND):
		if light_area in player.in_light_arr:
			change_state(State.ATTACK)
		else:
			change_state(State.CHASE)
		#print(rad_to_deg(rotation + player.global_position.angle_to_point(path_follow.global_position)))
		change_raycast_rotation(player.global_position.angle_to_point(path_follow.global_position))
		make_path()
		player.create_light_area()
	player.light_timer.start()

func set_dir(angle: float) -> void:
	#print(rad_to_deg(angle))
	change_raycast_rotation(angle) #TEMP SOLUTION (WHEN 8 DIRECTION ADDED WILL CHANGE)
	var direction_before: String = direction
	angle = fmod(angle + TAU * 6, TAU) - PI
	direction = "d" if angle < 0.01 else "u"
	if abs(angle) < PI / 3.0:
		direction = "l"
	elif abs(angle) > 2 * PI / 3.0:
		direction = "r"
	
	if direction_before != direction:
		animation_player.play(action + "_" + direction)

func set_up_raycast():
	for i in range(raycast_amt):
		raycast_ang -= 8
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
	if state == State.PATROL or state == State.CHASE or state == State.ATTACK:
		angle += deg_to_rad(-90)
	else:
		angle += deg_to_rad(90)
	var ori_angle = angle
	for i in range(raycast_arr.size()):
		raycast_arr[i].rotation = angle
		line_arr[i].rotation = angle
		if raycast_arr.size()/2 > i: #part 1
			angle += deg_to_rad(8)
		elif floor(raycast_arr.size()/2) == i: #part 2
			angle = ori_angle
			angle += deg_to_rad(-8)
		else: #part 3
			angle += deg_to_rad(-8)

func attack():
	var new_bullet = bullet.instantiate()
	new_bullet.dir = player.global_position.angle_to_point(character.global_position) + deg_to_rad(270)
	new_bullet.global_position = character.global_position
	new_bullet.rotation = player.global_position.angle_to_point(character.global_position)
	new_bullet.visible = true
	new_bullet.z_index = 1
	add_child(new_bullet)

func make_path():
	chase_timer.start()
	#print(nav.target_position)

func _on_attack_timer_timeout():
	attack()

func _on_chase_timer_timeout():
	nav.target_position = player.global_position

func _on_light_area_body_exited(body):
	if state == State.ATTACK:
		change_state(State.CHASE)

func _on_wait_timer_timeout():
	change_state(State.PATROL)
	#print(state)
