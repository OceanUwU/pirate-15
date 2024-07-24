extends Node2D

# exports for editor
@export var fog: Sprite2D
@export var fogWidth = 1280
@export var fogHeight = 720
@export var LightTexture: CompressedTexture2D
@export var lightWidth = 300
@export var lightHeight = 300
@export var light_arr: Array[Area2D]
@export var debounce_time = 0.01

# debounce counter helper
var time_since_last_fog_update = 0.0

var fogImage: Image
var lightImage: Image
var light_offset: Vector2
var fogTexture: ImageTexture
var light_rect: Rect2

func _ready():
	lightImage = LightTexture.get_image()

func create_light(shape):
	lightImage.resize(shape.size, shape.size)
	light_offset = Vector2(shape.size / 2, shape.size / 2)
	light_rect = Rect2(Vector2.ZERO, lightImage.get_size())
	fogImage.blend_rect(lightImage, light_rect, shape.global_position - light_offset)

func create_fog():
	fogImage = Image.create(fogWidth, fogHeight, false, Image.FORMAT_RGBA8)
	fogImage.fill(Color(0.3, 0.3, 0.3, 1))

func _process(delta):
	time_since_last_fog_update += delta
	if time_since_last_fog_update >= debounce_time:
		create_fog()
		for i in range(light_arr.size()):
			create_light(light_arr[i])
		time_since_last_fog_update = 0.0
		fogTexture = ImageTexture.create_from_image(fogImage)
		fog.texture = fogTexture
