extends TextureButton

const BattleUnits = preload("res://Resources/BattleUnits.tres")

signal description_changed


func _on_LevelInspectButton_pressed() -> void:
	emit_signal("description_changed", "Current level")
