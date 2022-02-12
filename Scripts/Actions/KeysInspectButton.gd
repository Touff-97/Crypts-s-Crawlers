extends TextureButton

const BattleUnits = preload("res://Resources/BattleUnits.tres")

signal description_changed


func _on_KeysInspectButton_pressed() -> void:
	emit_signal("description_changed", "Obtained keys")
