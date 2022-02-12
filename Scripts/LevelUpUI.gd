extends Control

const BattleUnits = preload("res://Resources/BattleUnits.tres")

onready var levelLabel = $Margin/VBox/Level


func _on_LevelUp_visibility_changed() -> void:
	levelLabel.text = str(BattleUnits.PlayerStats.level)


func _on_Back_pressed() -> void:
	visible = !visible

