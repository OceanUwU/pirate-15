extends Node2D

@onready var stealth_bgm = $StealthBGM
@onready var battle_bgm = $BattleBGM
@onready var curr_bgm = stealth_bgm


func _ready():
	curr_bgm.play()
	#battle_bgm.play()
