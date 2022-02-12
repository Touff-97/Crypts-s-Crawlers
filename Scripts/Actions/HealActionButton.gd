extends "res://Scripts/ActionButton.gd"

onready var info = $InputInfo


func _on_pressed() -> void:
	var playerStats = BattleUnits.PlayerStats
	var effect = int(playerStats.max_hp * 0.4)
	if playerStats != null:
		if playerStats.mp >= 8 and playerStats.hp < playerStats.max_hp:
			$Audio/Heal.play()
			playerStats.hp += effect
			playerStats.mp -= 8
			playerStats.ap -= 1
	display_info(info)
