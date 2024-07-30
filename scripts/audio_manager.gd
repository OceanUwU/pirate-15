extends Node2D

@onready var stealth_bgm = $StealthBGM
@onready var battle_bgm = $BattleBGM


func _ready():
	battle_bgm.play()
	#battle_bgm.play()
