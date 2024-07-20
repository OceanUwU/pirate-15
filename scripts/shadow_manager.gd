extends Node2D

@export var shadow_arr: Array[CollisionPolygon2D]
@export var light_arr: Array[CollisionShape2D]

@onready var polygon = $Polygon2D

func _ready():
	print(shadow_arr[0].polygon)
	polygon.polygon = shadow_arr[0].polygon
	polygon.modulate = 100

func _process(delta):
	pass
