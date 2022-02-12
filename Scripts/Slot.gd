extends Button

const BattleUnits = preload("res://Resources/BattleUnits.tres")

# warning-ignore:unused_signal
signal description_changed
# warning-ignore:unused_signal
signal sound_fx(sound)


func _on_pressed() -> void:
	var playerStats = BattleUnits.PlayerStats
	# Take the effect of the loaded item
	take_effect()
	# Use up the item
	playerStats.use_item(self.name)
	print("Item used.")


func take_effect() -> void:
	pass
