extends "res://Scripts/ActionButton.gd"

onready var info = $InputInfo


func _on_pressed() -> void:
	display_info(info)
