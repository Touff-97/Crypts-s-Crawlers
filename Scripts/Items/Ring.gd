extends "res://Scripts/Slot.gd"

var description : String = "Ring.\nFits all fingers"
var item_icon = preload("res://Assets/Sprites/Items/Loot/ring.svg")


func _on_pressed() -> void:
	var playerStats = BattleUnits.PlayerStats
	# Take the effect of the loaded item
	take_effect()
	# Use up the item
	playerStats.use_item(self.name, true)
	print("Item used.")


func take_effect() -> void:
	display_info(find_node("InputInfo"))
	# Actual functionality for a unique item
	# This one is a junk/sellable item only


func update_info() -> void:
	find_node("InputInfo").description = self.description


func display_info(source) -> void:
	emit_signal("description_changed", source.retrieve_info())
