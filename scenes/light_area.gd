extends Area2D

@export var collision_shape:CollisionShape2D

var size:int


func _ready():
	size = collision_shape.shape.radius*2
	print(size)
