extends Area2D

@onready var collision_shape = $CollisionShape2D
@export var size: int = 400


func _ready():
	collision_shape.shape.radius = size/2
