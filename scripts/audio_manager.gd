extends Node2D

@onready var stealth_bgm = $StealthBGM
@onready var battle_bgm = $BattleBGM


func _ready():
	stealth_bgm.play()
	#battle_bgm.play()
