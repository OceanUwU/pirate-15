extends CharacterBody2D

@onready var raycast = $RayCast2D

func _physics_process(delta):
	if raycast.is_colliding():
		print("collide")

func set_up():
	pass

func duplicate_raycast():
	pass
