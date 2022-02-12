extends "res://Scripts/ActionButton.gd"

onready var info = $InputInfo


func _on_pressed() -> void:
	var playerStats = BattleUnits.PlayerStats
	playerStats.search_inventory()
	display_info(info)
