extends Node2D

# exports for editor
@export var fog: Sprite2D
@export var LightTexture: CompressedTexture2D
@export var lightWidth = 300
@export var lightHeight = 300
@export var light_arr: Array[Area2D]
@export var debounce_time = 0.01
@export var curr_level: Node2D

# debounce counter helper
var time_since_last_fog_update = 0.0

var fogImage: Image
var lightImage: Image
var light_offset: Vector2
var fogTexture: ImageTexture
var light_rect: Rect2
var light_diff = 20
var fogWidth: int
var fogHeight: int

func _ready():
	lightImage = LightTexture.get_image()
	fogWidth = curr_level.size.x
	fogHeight = curr_level.size.y

func create_light(shape):
	var light_size = shape.size + light_diff
	var resized_light_image = lightImage.duplicate()
	resized_light_image.resize(light_size, light_size)
	light_offset = Vector2(light_size / 2, light_size / 2)
	light_rect = Rect2(Vector2.ZERO, resized_light_image.get_size())
	fogImage.blend_rect(resized_light_image, light_rect, shape.global_position - light_offset)

func create_fog():
	fogImage = Image.create(fogWidth, fogHeight, false, Image.FORMAT_RGBA8)
	fogImage.fill(Color(0.3, 0.3, 0.3, 1))

func _process(delta):
	time_since_last_fog_update += delta
	if time_since_last_fog_update >= debounce_time:
		create_fog()
		for i in range(light_arr.size()):
			if !light_arr[i].process_mode:
				create_light(light_arr[i])
		time_since_last_fog_update = 0.0
		fogTexture = ImageTexture.create_from_image(fogImage)
		fog.texture = fogTexture
