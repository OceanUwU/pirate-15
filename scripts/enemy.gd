class_name Enemy extends Path2D

enum Direction { UP, UP_RIGHT, DOWN, DOWN_RIGHT }

@export var character: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var path_follow: PathFollow2D
@export var animation_player: AnimationPlayer
@export var roam_speed: float
var following_path: bool = true
var direction: String = "up"
var action: String = "walk"

func _ready() -> void:
	animation_player.play(action + "_" + direction)

func _physics_process(delta: float) -> void:
	if following_path:
		var path_pos_before: Vector2 = path_follow.position
		path_follow.progress += roam_speed * delta
		set_dir(path_pos_before.angle_to_point(path_follow.position))

func set_dir(angle: float) -> void:
	var direction_before: String = direction
	angle = fmod(angle + TAU * 6, TAU) - PI
	direction = "down" if angle < 0.01 else "up"
	if abs(angle) < PI / 3.0:
		direction += "_left"
	elif abs(angle) > 2 * PI / 3.0:
		direction += "_right"
	
	if direction_before != direction:
		animation_player.play(action + "_" + direction)
