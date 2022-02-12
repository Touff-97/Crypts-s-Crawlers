extends Control

const BattleUnits = preload("res://Resources/BattleUnits.tres")

onready var input_line = $Background/Margin/VBox/Input/LineEdit
onready var output_line = $Background/Margin/VBox/Output/VBox

signal inventory_toggled


func _ready() -> void:
	input_line.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cheat"):
		toggle_visibility()


func _on_CheatConsole_visibility_changed() -> void:
	if visible:
		input_line.grab_focus()


func toggle_visibility() -> void:
	self.visible = !visible


### CHEAT CONSOLE ###

func _on_LineEdit_text_changed(new_text: String) -> void:
	if new_text == "º":
		toggle_visibility()
		input_line.text = ""


func _on_LineEdit_text_entered(new_text: String) -> void:
	# Split input words into an array
	var input_words = new_text.split(" ")
	# Proccess the words individually
	if input_words.size() == 3:
		command_processor(input_words[0].to_lower(), input_words[1], int(input_words[2]))
	elif input_words.size() == 2:
		command_processor(input_words[0].to_lower(), input_words[1])
	else:
		command_processor(input_words[0].to_lower(), "")
	# Reset input
	input_line.text = ""


func command_processor(key_word: String, first_word: String, amount: int = 1) -> void:
	match key_word:
		"print":
			output_text(print_command(first_word, amount))
		
		"give":
			output_text(give_command(first_word, amount))
			toggle_visibility()
		
		"coin":
			output_text(coin_command(first_word, amount))
		
		"restore":
			output_text(restore_command())
			toggle_visibility()
		
		"kill":
			output_text(kill_command())
			toggle_visibility()
		
		"inventory":
			output_text(inventory_command())
			toggle_visibility()
		
		"exp":
			output_text(exp_command(int(first_word)))
			toggle_visibility()
		
		"help":
			output_text(help_command(first_word))
		
		_:
			return


func output_text(output: String) -> void:
	var new_entry = Label.new()
	new_entry.text = " > " + output + "\n"
	new_entry.autowrap = true
	output_line.add_child(new_entry)


### COMMANDS ###

func print_command(word: String, _amount: int) -> String:
	# For simple testing purposes
	return "User: " + word


func give_command(item: String, amount: int) -> String:
	var playerStats = BattleUnits.PlayerStats
	# The actual effect
	playerStats.pick_item(item, amount)
	# To display on output
	return "Gave " + str(amount) + " " + item


func coin_command(action: String, amount: int) -> String:
	var playerStats = BattleUnits.PlayerStats
	# The actual effect
	match action:
		"get":
			playerStats.coins += amount
			toggle_visibility()
			return str(amount) + " coins acquired."
		
		"remove":
			if playerStats.coins - amount > 0:
				playerStats.coins -= amount
				toggle_visibility()
				return str(amount) + " coins removed."
			return "Error: Invalid Amount."
		
		_:
			return "Error: Incorrect Input."


func restore_command() -> String:
	var playerStats = BattleUnits.PlayerStats
	# The actual effect
	playerStats.hp += playerStats.max_hp
	playerStats.mp += playerStats.max_mp
	playerStats.ap += playerStats.max_ap
	# To display on output
	return "Player fully restored."


func kill_command() -> String:
	var enemy = BattleUnits.Enemy
	# The actual effect
	if enemy != null:
		enemy.take_damage(enemy.max_hp)
		# To display on output
		return "Enemy killed."
	return "No enemy to kill."


func inventory_command() -> String:
	emit_signal("inventory_toggled")
	return "Inventory opened."


func exp_command(amount: int) -> String:
	var playerStats = BattleUnits.PlayerStats
	playerStats.experience += amount
	return str(amount) + "exp added."


func help_command(command: String = "") -> String:
	if command == "":
		return "List of commands: [\n        Print\n        Give\n        Coin\n        Restore\n        Kill\n    ]"
	else:
		match command.to_lower():
			"print":
				return "Prints a word."
			
			"give":
				return "Returns the specified item.\nGive [item] [amount]"
			
			"coin":
				return "Gives or takes coins.\nCoin [get] [amount]\nCoin [remove] [amount]"
			
			"restore":
				return "Restores the player's points to maximum capacity."
			
			"kill":
				return "Kills current enemy."
			
			"Inventory":
				return "Opens up inventory."
			
			"Exp":
				return "Adds specified amount of experience points.\nExp [amount]"
			
	return "Error: Invalid Arguement."
