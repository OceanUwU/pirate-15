extends Node2D

@onready var player = $Player
@onready var audio_manager = $AudioManager
@onready var curr_level = $Level

func _on_potion_buff_player():
	player.buff()
