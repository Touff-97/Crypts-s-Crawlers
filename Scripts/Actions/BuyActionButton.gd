extends "res://Scripts/ActionButton.gd"

onready var info = $InputInfo
onready var label = $Label

export(Array, String) var items = []

signal item_bought(item, price)


func _ready() -> void:
	randomize()
	# Set the name of the item randomly
	var items_dup = items.duplicate()
	items_dup.shuffle()
	self.name = items_dup.pop_front()
	
	# Change the icon by its name
	match self.name:
		"crown", "crystal", "key", "ring", "rupee":
			self.icon = load("res://Assets/Sprites/Items/Loot/" + self.name + ".svg")
		
		"bomb", "flame", "poison", "potion":
			self.icon = load("res://Assets/Sprites/Items/" + self.name + ".svg")
		
		_:
			return
	
	# Randomly generate the amount to be sold
	if self.name != "rupee":
		label.text = str(randi() % 24 + (3 * 1)) + "c"
	else:
		label.text = str(randi() % 7 + 1) + "c"
	
	# Set its description
	info.description = self.name.capitalize() + ".\nSold for " + label.text


func _on_pressed() -> void:
	if BattleUnits.PlayerStats.coins - int(label.text) >= 0:
		emit_signal("item_bought", self.name, int(label.text))
	display_info(info)
