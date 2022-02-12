extends "res://Scripts/Slot.gd"

var description : String = "Poison.\nPoisons target"
var item_icon = preload("res://Assets/Sprites/Items/poison.svg")


func take_effect() -> void:
	var enemy = BattleUnits.Enemy
	var playerStats = BattleUnits.PlayerStats
	
	display_info(find_node("InputInfo"))
	
	yield(get_tree().create_timer(1.0), "timeout")
	# Actual functionality for a unique item
	emit_signal("sound_fx", "Poison")
	enemy.take_damage(1)
	if enemy != null:
		enemy.afflicted = true
		enemy.affliction = "Poison"
		enemy.affliction_duration = randi() % 3 + 1
		enemy.sprite.modulate = Color(0.69, 0.88, 0.61, 1.0)
	# It's important that this comes after because if you run out of Action Points,
	# the enemy's turn starts before the damage and other effects take effect.
	playerStats.ap -= 1


func update_info() -> void:
	find_node("InputInfo").description = self.description


func display_info(source) -> void:
	emit_signal("description_changed", source.retrieve_info())
