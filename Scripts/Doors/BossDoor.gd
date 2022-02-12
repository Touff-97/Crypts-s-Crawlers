extends "res://Scripts/Door.gd"

onready var info = $InputInfo


func _on_InspectButton_pressed() -> void:
	display_info(info)

