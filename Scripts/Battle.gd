extends Node

const BattleUnits = preload("res://Resources/BattleUnits.tres")
const NextFloor = preload("res://Scenes/Doors/NextFloorDoor.tscn")

export(Array, PackedScene) var doors = []
export(Array, PackedScene) var enemies = []
export(Array, PackedScene) var mobs = []
export(Array, PackedScene) var bosses = []
export(Array, PackedScene) var special = []
export(Array, NodePath) var Ambient = []

onready var battleActionButtons = $VBoxContainer/UI/VBox/BattleActionButtons/ScrollContainer/Grid
onready var animPlayer = $AnimationPlayer
onready var nextRoomButton = $VBoxContainer/NextRoom/NextRoomButton
onready var enemyPosition = $VBoxContainer/NextRoom/EnemyPosition
onready var gameOverScreen = $GameOver
onready var gameOverButton = $GameOver/VBox/GameOverButton
onready var winScreen = $WinScreen
onready var winScreenButton = $WinScreen/Margin/VBox/GameOverButton
onready var descriptionLabel = $VBoxContainer/UI/VBox/BottomUI/MarginContainer/DescriptionPanel/MarginContainer/DescriptionLabel
onready var inventory = $Inventory
onready var experience_bar = $VBoxContainer/Experience/HBox/ExperienceBar
onready var level_label = $VBoxContainer/Experience/HBox/LevelLabel
onready var exp_label = $VBoxContainer/Experience/HBox/ExperienceBar/ExpLabel
onready var level_up_popup = $LevelUp
onready var purseAnim = $VBoxContainer/UI/VBox/BottomUI/Margin/Purse/AnimationPlayer
onready var purseLabel = $VBoxContainer/UI/VBox/BottomUI/Margin/Purse/Label
onready var doorLabel = $VBoxContainer/UI/VBox/BottomUI/Margin/Doors/Label
onready var floorLabel = $VBoxContainer/UI/VBox/BottomUI/Margin/Doors/Label2
onready var keyAnim = $VBoxContainer/UI/VBox/BottomUI/Margin/Keys/AnimationPlayer
onready var keyLabel = $VBoxContainer/UI/VBox/BottomUI/Margin/Keys/Label
onready var run_button = $VBoxContainer/UI/VBox/BattleActionButtons/ScrollContainer/Grid/RunActionButton

var floor_size : int = 0
var floor_level : int = 1

signal end


func _ready() -> void:
	randomize()
	
	floor_size = randi() % 5 + 4
	doorLabel.text = str(floor_size - 1)
	floorLabel.text = str(floor_level)
	
	toggle_disable_actions()
	
	start_player_turn()
	
	var enemy = BattleUnits.Enemy
	if enemy != null:
		print("Enemy connected!")
		enemy.connect("description_changed", self, "_on_description_changed")
		enemy.connect("died", self, "_on_Enemy_died")


### CUSTOM FUNCTIONS ###


func start_enemy_turn() -> void:
	battleActionButtons.hide()
	
	var enemy = BattleUnits.Enemy
	
	if enemy != null and not enemy.is_queued_for_deletion():
		print("\nEnemy's Turn:\n")
		# Takes into account the time for an item to deal damage due to fade transitions
		yield(get_tree().create_timer(1.1), "timeout")
		# If you used an item with 1ap left, your turn ends and the enemy attacks while still taking damage from the item
		# So yield for the duration of the animation and then attack
		if enemy.animPlayer.is_playing():
			yield(enemy.animPlayer, "animation_finished")
		enemy.attack()
		yield(enemy, "end_turn")
	# Go to player's turn
	start_player_turn()


func start_player_turn() -> void:
	battleActionButtons.show()
	
	var playerStats = BattleUnits.PlayerStats
	if playerStats.hp > 0:
		print("\nPlayer's Turn:\n")
		playerStats.ap = playerStats.max_ap
		# Reset blocking boolean in PlayerStats
		if playerStats.blocking:
			playerStats.blocking = false
			playerStats.block_modifier = 1.0
	yield(playerStats, "end_turn")
	# Go to enemy's turn
	start_enemy_turn()


func create_new_door() -> void:
	var door_index : int
	
	if (randi() % 100 + 1) > 80 and floor_level > 1:
		door_index = randi() % 3 + 1
		print("Special door #", door_index)
	else:
		door_index = 0
	
	var Door = doors[door_index]
	var new_door = Door.instance()
	enemyPosition.add_child(new_door)
	new_door.connect("description_changed", self, "_on_description_changed")
	new_door.connect("door_entered", self, "_on_door_entered")
	
	# Play random ambient noise
	if randi() % 100 + 1 > 70:
		print("Creepy noise")
		var ambient = Ambient.duplicate()
		ambient.shuffle()
		var new_ambient = ambient.pop_front()
		get_node(new_ambient).play()


func create_new_enemy() -> void:
	var playerStats = BattleUnits.PlayerStats
	var enemy_index : int
	
	enemy_index = playerStats.level - 1
	print("Enemy: ", enemy_index)
	var Enemy : PackedScene
	
	if (randi() % 100 + 1) > 80: # Special side mob
		Enemy = mobs[enemy_index]
	else:
		Enemy = enemies[enemy_index]
	
	var new_enemy = Enemy.instance()
	enemyPosition.add_child(new_enemy)
	new_enemy.connect("description_changed", self, "_on_description_changed")
	new_enemy.connect("died", self, "_on_Enemy_died")


func create_new_boss() -> void:
	var playerStats = BattleUnits.PlayerStats
	var boss_index : int
	var Boss : PackedScene
	
	if playerStats.level < playerStats.max_level:
		# warning-ignore:narrowing_conversion
		boss_index = clamp(playerStats.level, 1, enemies.size() - 1)
		Boss = enemies[boss_index]
	else:
#		boss_index = randi() % 9
		boss_index = 8
		Boss = enemies[boss_index]
	
	var new_boss = Boss.instance()
	enemyPosition.add_child(new_boss)
	new_boss.connect("description_changed", self, "_on_description_changed")
	new_boss.connect("died", self, "_on_Boss_died")
	
	run_button.disabled = false
	print("Run button disabled = ", run_button.is_disabled())


func create_new_shop() -> void:
	var Shop = special[0]
	var new_shop = Shop.instance()
	enemyPosition.add_child(new_shop)
	new_shop.connect("description_changed", self, "_on_description_changed")
	new_shop.connect("shopped", self, "_on_PlayerStats_shopped")


func create_new_treasure() -> void:
	var Treasure = special[1]
	var new_treasure = Treasure.instance()
	enemyPosition.add_child(new_treasure)
	new_treasure.connect("description_changed", self, "_on_description_changed")
	new_treasure.connect("looted", self, "_on_PlayerStats_looted")


func create_new_trap() -> void:
	var Trap = special[2]
	var new_trap = Trap.instance()
	enemyPosition.add_child(new_trap)
	new_trap.connect("description_changed", self, "_on_description_changed")
	new_trap.connect("trapped", self, "_on_PlayerStats_trapped")


func toggle_disable_actions() -> void:
	var action_buttons = battleActionButtons.get_children()
	for i in action_buttons:
		i.disabled = !i.disabled


func point_takeaway() -> void:
	var playerStats = BattleUnits.PlayerStats

	if playerStats.mp > 0:
		playerStats.mp -= 2


### SIGNALS ###


func _on_Enemy_died(exp_drop: int, coin_drop: int, _loot_drop: String = "") -> void:
	var playerStats = BattleUnits.PlayerStats
	var enemy = BattleUnits.Enemy
	print("Enemy died")
	# Reset after running
	if enemy.dodged:
		enemy.dodged = false
	# Drops
	playerStats.experience += exp_drop
	playerStats.coins += coin_drop
#	if loot_drop != "":
#		playerStats.pick_item(loot_drop, randi() % 3 + 1)
	# After death
	nextRoomButton.show()
	battleActionButtons.hide()
	toggle_disable_actions()


func _on_Boss_died(exp_drop: int, coin_drop: int, loot_drop: String = "") -> void:
	var playerStats = BattleUnits.PlayerStats
	# Drops
	playerStats.experience += exp_drop * 2
	playerStats.coins += (coin_drop * 2) + 12
	if loot_drop != "":
		playerStats.pick_item(loot_drop, randi() % 3 + 1)
	# After death
	var max_exp : int = 36288000 # Max exp at level 9
	if not playerStats.experience >= max_exp:
		var next_floor = NextFloor.instance()
		enemyPosition.add_child(next_floor)
		next_floor.connect("description_changed", self, "_on_description_changed")
		next_floor.connect("door_entered", self, "_on_door_entered")
		run_button.disabled = false
	else:
		print("You win!")
		# Populate the end screen labels
		for key in playerStats.inventory:
			if playerStats.inventory[key] != null:
				match playerStats.inventory[key]["item"]:
					"Crown":
						winScreen.find_node("Crown").text = str(playerStats.inventory[key]["amount"])
					
					"Crystal":
						winScreen.find_node("Crystal").text = str(playerStats.inventory[key]["amount"])
					
					"Ring":
						winScreen.find_node("Ring").text = str(playerStats.inventory[key]["amount"])
					
					"Rupee":
						winScreen.find_node("Rupee").text = str(playerStats.inventory[key]["amount"])
					
					_:
						return
		
		winScreen.find_node("Coins").text = str(playerStats.coins)
		winScreen.show()
		$Audio/Win.play()
		# Convert all valuables into coins
		yield($Audio/Win, "finished")
		var items = [winScreen.find_node("Crown"), winScreen.find_node("Crystal"), winScreen.find_node("Ring"), winScreen.find_node("Rupee")]
		for i in items:
			while int(i.text) > 0:
				i.text = str(int(i.text) - 1)
				winScreen.find_node("Coins").text = str(int(winScreen.find_node("Coins").text) + 1)
				# Future addition of sound here
				$Audio/ConvertToCoin.play()
				yield($Audio/ConvertToCoin, "finished")
		playerStats.coins = int(winScreen.find_node("Coins").text)
		# Show the Try Again button
		winScreenButton.show()
	toggle_disable_actions()


func _on_NextRoomButton_pressed() -> void:
	var playerStats = BattleUnits.PlayerStats
	
	nextRoomButton.hide()
	animPlayer.play("fade")
	yield(animPlayer, "animation_finished")
	playerStats.ap = playerStats.max_ap
	battleActionButtons.show()
	print(str(floor_size) + " doors left.")
	if floor_size > 0:
		create_new_door()
	else:
		create_new_boss()
		toggle_disable_actions()


func _on_PlayerStats_experience_gained(new_amount) -> void:
	var playerStats = BattleUnits.PlayerStats
	experience_bar.set_value(new_amount)
	# Update experience label
	exp_label.text = str(playerStats.experience) + "/" + str(playerStats.exp_cap)


func _on_PlayerStats_levelled_up(new_amount) -> void:
	var playerStats = BattleUnits.PlayerStats
	experience_bar.set_max(new_amount)
	# SoundFX
	$Audio/LevelUp.play()
	# Reset values to the max
	playerStats.max_hp = 10 + (5 * playerStats.level)
	playerStats.hp = playerStats.max_hp
	playerStats.mp = playerStats.max_mp
	# Update level label
	level_label.text = str(playerStats.level)
	# Popup
	animPlayer.play("fade")
	yield(get_tree().create_timer(0.5), "timeout")
	level_up_popup.visible = true


func _on_PlayerStats_coin_get(new_amount) -> void:
	print("Coins get: ", new_amount - int(purseLabel.text))
	if new_amount - int(purseLabel.text):
		$Audio/CoinGet.play()
		purseAnim.play("blink")
	purseLabel.text = str(new_amount)
	


func _on_PlayerStats_inventory_toggled() -> void:
	animPlayer.play("fade")
	yield(get_tree().create_timer(0.5), "timeout")
	inventory.visible = !inventory.visible


func _on_PlayerStats_item_picked(slot) -> void:
	var playerStats = BattleUnits.PlayerStats
	
	var slot_node = "Margin/VBox/Grid/" + slot
	var item = playerStats.inventory[slot]["item"]
	var amount = playerStats.inventory[slot]["amount"]
	
	# Set the inventory button to the item's name and amount
	inventory.get_node(slot_node).text = item + "(" + str(amount) + ") "
	# Set disable to false so it can be pressed
	inventory.get_node(slot_node).disabled = false
	# Load the correct item's script to the button (extends the Slot.gd script)
	inventory.get_node(slot_node).script = load("res://Scripts/Items/" + item.capitalize() + ".gd")
	# Set the Item's description
	inventory.get_node(slot_node).update_info()
	# Set the Item's icon
	inventory.get_node(slot_node).icon = inventory.get_node(slot_node).item_icon
	# Refresh UI based on if Item is a key
	if item.to_lower() == "key":
		keyLabel.text = str(amount)
		$Audio/KeysGet.play()
		keyAnim.play("blink")
		return


func _on_PlayerStats_item_used(slot, new_amount) -> void:
	var playerStats = BattleUnits.PlayerStats
	
	var slot_node = "Margin/VBox/Grid/" + slot
	var item = playerStats.inventory[slot]["item"]
	var amount = playerStats.inventory[slot]["amount"]
	
	# Update the keys UI
	if item.to_lower() == "key":
		keyLabel.text = str(new_amount)
		keyAnim.play("blink")
	
	# Update the Inventory Slot's text and other properties
	if new_amount > 0:
		inventory.get_node(slot_node).text = "(" + str(amount) + ") " + item
	else:
		yield(get_tree().create_timer(2.0), "timeout")
		inventory.get_node(slot_node).text = ""
		inventory.get_node(slot_node).icon = null
		inventory.get_node(slot_node).disabled = true
		inventory.get_node(slot_node).script = load("res://Scripts/Slot.gd")


func _on_PlayerStats_shopped(item: String = "", price: int = 0) -> void:
	var playerStats = BattleUnits.PlayerStats
	if not item == "":
		playerStats.pick_item(item.capitalize(), 1)
		playerStats.coins -= price
	nextRoomButton.show()
	battleActionButtons.hide()


func _on_PlayerStats_looted() -> void:
	nextRoomButton.show()


func _on_PlayerStats_trapped() -> void:
	nextRoomButton.show()


func _on_PlayerStats_PlayerDied() -> void:
	print("\nGame Over!\n")
	emit_signal("end")
	$Audio/Death.play()
	battleActionButtons.hide()
	gameOverScreen.show()
	animPlayer.play("game_over")
	yield(animPlayer, "animation_finished")
	gameOverButton.show()


func _on_GameOverButton_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()


func _on_description_changed(description: String) -> void:
	descriptionLabel.text = description
	$Audio/Description.play()


func _on_door_entered(type: int) -> void:
	var playerStats = BattleUnits.PlayerStats
	
	$Audio/Door.play()
	
	descriptionLabel.text = "You enter."
	animPlayer.play("fade")
	yield(animPlayer, "animation_finished")
	
	# Countdown to boss battle
	if floor_size > 0:
		floor_size -= 1
	
	if type != 0:
		doorLabel.text = str(floor_size)
	
	# Choose the next scene based on the door type
	match type:
		0: # Entrance door
			print("Creating new door!")
			create_new_door()
		1: # Enemy door
			print("Creating new enemy!")
			create_new_enemy()
			toggle_disable_actions()
		2: # Shop door
			print("Creating new shop!")
			create_new_shop()
		3: # Treasure door
			print("Creating new treasure!")
			create_new_treasure()
		4: # Trap door
			print("Creating new trap!")
			create_new_trap()
		5: # Boss door
			pass
		6: # Next floor door
			print("Creating new floor!")
			playerStats.ap = playerStats.max_ap
			create_new_door()
			# Raise the difficulty level
			floor_level += 1
			floorLabel.text = str(floor_level)
			# Reset floor size
			floor_size = randi() % 9 + (3 * floor_level)
			# To force update the door counter for the next floor
			doorLabel.text = str(floor_size)
		_:
			return
