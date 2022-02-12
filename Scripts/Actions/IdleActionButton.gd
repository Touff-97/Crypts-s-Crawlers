extends "res://Scripts/ActionButton.gd"

onready var info = $InputInfo


func _on_pressed() -> void:
	var playerStats = BattleUnits.PlayerStats
	if playerStats != null:
		if playerStats.ap > 0:
			if playerStats.hp < playerStats.max_hp or playerStats.mp < playerStats.max_mp:
				playerStats.hp += ceil(playerStats.max_hp * 0.1)
				playerStats.ap -= 1
				playerStats.mp += playerStats.max_mp * 0.1
	display_info(info)
