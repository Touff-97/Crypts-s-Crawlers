extends Node2D

const BattleUnits = preload("res://Resources/BattleUnits.tres")
const Mimic = preload("res://Scenes/Enemies/Mimic.tscn")

export(Array, String) var chests = []
export(Array, String) var loot = []

onready var sprite = $Sprite
onready var open_button = $OpenActionButton
onready var exit = $Sprite/Exit

signal description_changed
signal looted


func _on_OpenActionButton_chest_opened() -> void:
	var playerStats = BattleUnits.PlayerStats
	# Verify if player has a key and remove it from the inventory
	for key in playerStats.inventory.keys():
		if playerStats.inventory[key] != null and playerStats.inventory[key]["item"] == "Key":
			$Audio/Unlock.play()
			playerStats.use_item(key)
			yield(get_tree().create_timer(0.5), "timeout")
			# Open chest, change its texture and hide the open button
			var chests_dup : Array = chests.duplicate()
			chests_dup.shuffle()
			var new_chest : String = chests_dup.pop_front()
			sprite.texture = load("res://Assets/Sprites/Treasure/" + new_chest + ".svg")
			open_button.hide()
			# After opening:
			var root_node = get_parent().get_parent().get_parent().get_parent()
			match new_chest:
				"empty":
					emit_signal("description_changed", "An empty chest...")
				
				"treasure":
					emit_signal("description_changed", "Treasure!")
					# Receive coins
					playerStats.coins += randi() % 42 + (12 * playerStats.level)
					# Receive loot item
					var loot_dup = loot.duplicate()
					loot_dup.shuffle()
					var new_loot = loot_dup.pop_front()
					playerStats.pick_item(new_loot.capitalize(), 1)
					playerStats.pick_item("Rupee", randi() % 9 + 3)
				
				"mimic":
					emit_signal("description_changed", "Oh no...")
					var new_mimic = Mimic.instance()
					new_mimic.max_hp = 42 + (4 * playerStats.level)
					new_mimic.damage = 2 + playerStats.level
					new_mimic.experience = 30 + (20 * playerStats.level)
					new_mimic.find_node("InputInfo").description = "Mimic.\nHP " + str(new_mimic.max_hp) + " | DMG " + str(new_mimic.damage) 
					# Get Battle node
					root_node.find_node("EnemyPosition").add_child(new_mimic)
					new_mimic.connect("description_changed", root_node, "_on_description_changed")
					new_mimic.connect("died", root_node, "_on_Enemy_died")
					root_node.toggle_disable_actions()
					# Toggle inventory before this queues free
					$Audio/Open.play()
					yield($Audio/Open, "finished")
					root_node._on_PlayerStats_inventory_toggled()
					queue_free()
				
				_:
					return
			$Audio/Open.play()
			yield($Audio/Open, "finished")
			root_node._on_PlayerStats_inventory_toggled()


func _on_OpenActionButton_description_changed(description: String) -> void:
	emit_signal("description_changed", description)


func _on_Exit_pressed() -> void:
	$Audio/Exit.play()
	yield($Audio/Exit, "finished")
	print("Exit")
	emit_signal("looted")
	queue_free()
