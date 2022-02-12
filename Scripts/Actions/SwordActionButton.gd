extends "res://Scripts/ActionButton.gd"

const Slash = preload("res://Scenes/Slash.tscn")

onready var info = $InputInfo

var damage : int


func _on_pressed() -> void:
	var enemy = BattleUnits.Enemy
	var playerStats = BattleUnits.PlayerStats
	
	damage = 1 + playerStats.level
	
	if enemy != null and playerStats != null and playerStats.ap > 0:
		$Audio/Slash.play(1.05)
		create_slash(enemy.global_position)
		enemy.take_damage(damage)
		playerStats.mp += 2
		playerStats.ap -= 1
	display_info(info)


func create_slash(position) -> void:
	var slash = Slash.instance()
	var main = get_tree().current_scene
	main.add_child(slash)
	slash.global_position = position
