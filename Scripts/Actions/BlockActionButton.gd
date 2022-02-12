extends "res://Scripts/ActionButton.gd"

onready var info = $InputInfo


func _on_pressed() -> void:
	var playerStats = BattleUnits.PlayerStats
	
	if playerStats.ap > 0 and playerStats.mp >= 4 and not playerStats.blocking:
		var modifier = 2.0
		playerStats.block_modifier = modifier
		playerStats.blocking = true
		playerStats.mp -= 4
		playerStats.ap -= 1
	display_info(info)
