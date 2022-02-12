extends "res://Scripts/ActionButton.gd"

onready var info = $InputInfo

signal chest_opened


func _on_pressed() -> void:
	emit_signal("chest_opened")
	display_info(info)
