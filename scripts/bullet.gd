extends CharacterBody2D

@export var SPEED = 200

var dir: float

func _ready():
	pass
	#print("bullet_created")

func _physics_process(delta):
	velocity = Vector2(0, -SPEED).rotated(dir)
	move_and_slide()
	#print(position)
