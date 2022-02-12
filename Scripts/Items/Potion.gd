extends "res://Scripts/Slot.gd"

var description : String = "Potion.\nRestores 60% hp"
var item_icon = preload("res://Assets/Sprites/Items/potion.svg")


func _on_pressed() -> void:
	var playerStats = BattleUnits.PlayerStats
	if playerStats.hp < playerStats.max_hp:
		# Take the effect of the loaded item
		take_effect()
		# Use up the item
		playerStats.use_item(self.name)
		print("Item used.")


func take_effect() -> void:
	var playerStats = BattleUnits.PlayerStats
	
	display_info(find_node("InputInfo"))
	
	yield(get_tree().create_timer(1.0), "timeout")
	# Actual functionality for a unique item
	playerStats.hp += ceil(playerStats.max_hp * 0.6)
	emit_signal("sound_fx", "Potion")
	# It's important that this comes after because if you run out of Action Points,
	# the enemy's turn starts before the damage and other effects take effect.
	playerStats.ap -= 1


func update_info() -> void:
	find_node("InputInfo").description = self.description


func display_info(source) -> void:
	emit_signal("description_changed", source.retrieve_info())
