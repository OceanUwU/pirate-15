extends Area2D

signal buff_player

func _on_body_entered(body):
	emit_signal("buff_player")
