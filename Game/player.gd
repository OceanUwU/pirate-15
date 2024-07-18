extends CharacterBody2D

@export var speed = 80

func _physics_process(delta):
	get_input()
	move_and_collide(delta * velocity)

func get_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * speed

