extends Node

const BattleUnits = preload("res://Resources/BattleUnits.tres")

# Experience and Levels
onready var experience : int = 0 setget set_exp
onready var exp_cap : int = 100
onready var level : int = 1
onready var max_level : int = 9
# Hit Points
onready var max_hp : int = 15
onready var hp : int = max_hp setget set_hp
# Mana Points
onready var max_mp : int = 10
onready var mp : int = max_mp setget set_mp
# Action Points
onready var max_ap : int = 3
onready var ap : int = max_ap setget set_ap
# Inventory
onready var inventory : Dictionary = {
	"Slot0": null,
	"Slot1": null,
	"Slot2": null,
	"Slot3": null,
	"Slot4": null,
	"Slot5": null,
	"Slot6": null,
	"Slot7": null,
	"Slot8": null,
}
# Money
onready var coins : int = 0 setget set_coin
# Ability related
onready var blocking : bool = false
onready var block_modifier : float = 1.0

# Stat signals
signal hp_changed(value)
signal mp_changed(value)
signal ap_changed(value)
# Inventory signals
signal inventory_toggled
signal item_picked(slot)
signal item_used(slot, new_amount)
# Event signals
signal experience_gained(new_amount)
signal levelled_up(new_amount)
signal coin_get(new_amount)
signal end_turn
signal PlayerDied


# Setter getters
func set_hp(new_value: int) -> void:
# warning-ignore:narrowing_conversion
	hp = clamp(new_value, 0, max_hp)
	emit_signal("hp_changed", hp)
	if hp == 0:
		emit_signal("PlayerDied")


func set_mp(new_value: int) -> void:
# warning-ignore:narrowing_conversion
	mp = clamp(new_value, 0, max_mp)
	emit_signal("mp_changed", mp)


func set_ap(new_value: int) -> void:
# warning-ignore:narrowing_conversion
	ap = clamp(new_value, 0, max_ap)
	emit_signal("ap_changed", ap)
	if ap == 0:
		print("End turn signal sent.")
		emit_signal("end_turn")


func set_exp(new_value: int) -> void:
	experience = new_value
	print("Experience Points: ", experience, "\n")
	
	# On level up
	while experience >= exp_cap:
		if level < max_level:
			experience -= exp_cap
			level += 1
			exp_cap *= level
			
			emit_signal("levelled_up", exp_cap)
			
			print("Level Up!")
			print("Level: ", level)
			print("Exp: " + str(experience) + "/" + str(exp_cap) + "\n")
		else:
			experience = exp_cap
			break
	
	emit_signal("experience_gained", experience)


func set_coin(new_value: int) -> void:
	coins = new_value
	
	emit_signal("coin_get", coins)


# Prep functions
func _ready() -> void:
	BattleUnits.PlayerStats = self


func _exit_tree() -> void:
	BattleUnits.PlayerStats = null


# Custom functions
func take_damage(damage: int) -> void:
	# warning-ignore:narrowing_conversion
	self.hp -= floor(damage / block_modifier)
	$Hurt.play()
	print("Raw damage taken: ", damage)
	print("After Block damage taken: ", floor(damage / block_modifier))


func pick_item(item: String, amount: int) -> void:
	var item_dict: Dictionary = {"item": item, "amount": amount}
	
	# Search for item in iventory and add 1 to its amount
	for key in inventory.keys():
		if inventory[key] != null and inventory[key]["item"] == item:
			inventory[key]["amount"] += amount
			print("Added +" + str(amount) + " " + item)
			emit_signal("item_picked", key)
			return
	
	# If no item is found the item is added
	for key in inventory.keys():
		if inventory[key] == null:
			inventory[key] = item_dict
			print("Added " + item + " to " + key)
			emit_signal("item_picked", key)
			return
	
	# If there're no slots available, inventory is full!
	print("No more space in inventory! Free up some space.")


func use_item(slot: String, junk: bool = false) -> void:
	# Look up the item resource and trigger its effect.
	print(inventory[slot]["item"] + " used.")
	
	if not junk:
		if inventory[slot]["amount"] > 1:
			inventory[slot]["amount"] -= 1
			emit_signal("item_used", slot, inventory[slot]["amount"])
		else:
			emit_signal("item_used", slot, 0)
			inventory[slot] = null
		
		emit_signal("inventory_toggled")


func search_inventory() -> void:
	# Go to inventory screen
	emit_signal("inventory_toggled")
