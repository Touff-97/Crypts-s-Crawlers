extends Button

const BattleUnits = preload("res://Resources/BattleUnits.tres")

signal description_changed


func _on_pressed() -> void:
	pass


func display_info(source) -> void:
	emit_signal("description_changed", source.retrieve_info())
