extends TextureButton

const BattleUnits = preload("res://Resources/BattleUnits.tres")

signal description_changed


func _on_DoorsInspectButton_pressed() -> void:
	emit_signal("description_changed", "Unexplored rooms")
