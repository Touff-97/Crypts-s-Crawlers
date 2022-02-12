extends "res://Scripts/ActionButton.gd"

onready var info = $InputInfo


func _on_pressed() -> void:
	var playerStats = BattleUnits.PlayerStats
	var enemy = BattleUnits.Enemy
	
	if playerStats.ap > 0:
		playerStats.take_damage(randi() % enemy.damage + 1)
		enemy.dodged = true
		enemy.take_damage(enemy.max_hp)
		enemy.visible = false
	display_info(info)
