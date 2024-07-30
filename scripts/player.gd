extends CharacterBody2D

@export var move_speed : float = 150
@export var starting_direction : Vector2 = Vector2(0,1)
@export var hp: int

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var light_area = $LightArea
@onready var light_timer = $LightTimer

var in_light_arr = []

func _ready():
	update_animation_parameter(starting_direction)

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up") 
		)
		
	update_animation_parameter(input_direction)
	
	velocity = input_direction * move_speed
	pick_move_state()
	move_and_slide()
	#print(light_area.size)
	

func update_animation_parameter(move_input : Vector2):

	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/walk/blend_position", move_input)
		animation_tree.set("parameters/idle/blend_position", move_input)
		
func pick_move_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("walk")
	else:
		state_machine.travel("idle")

func create_light_area():
	light_area.global_position = global_position
	light_area.process_mode = Node.PROCESS_MODE_INHERIT

func _on_light_sense_area_entered(area):
	print(area)
	in_light_arr.append(area)

func _on_light_sense_area_exited(area):
	print("out")
	in_light_arr.remove_at(in_light_arr.find(area))

func _on_hurtbox_body_entered(body):
	pass # Replace with function body.

func _on_light_timer_timeout():
	light_area.process_mode = Node.PROCESS_MODE_DISABLED
