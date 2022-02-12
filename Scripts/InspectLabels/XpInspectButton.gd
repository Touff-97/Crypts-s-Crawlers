extends TextureButton

const BattleUnits = preload("res://Resources/BattleUnits.tres")

signal description_changed


func _on_XpInspectButton_pressed() -> void:
	print("Test")
	emit_signal("description_changed", "Experience gained")
