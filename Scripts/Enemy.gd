extends Node2D

const BattleUnits = preload("res://Resources/BattleUnits.tres")

export(int) var max_hp = 9
export(int) var damage = 3
export(int) var experience = 0
export(Array, String) var loot = []
export(Array, NodePath) var death_cries = []

onready var hp_label = $HPLabel
onready var sprite = $Sprite
onready var animPlayer = $AnimationPlayer

var hp : int = max_hp setget set_hp
var afflicted : bool = false
var affliction : String = ""
var affliction_duration : int = 0
var dodged : bool = false

signal description_changed
signal died(exp_drop, coin_drop, loot_drop)
signal end_turn


func set_hp(new_value) -> void:
	hp = new_value
	if hp_label != null:
		hp_label.text = str(new_value) + "hp"


func _ready() -> void:
	BattleUnits.Enemy = self
	hp_label.text = str(max_hp) + "hp"
	hp = max_hp


func _exit_tree() -> void:
	BattleUnits.Enemy = null


func attack() -> void:
	yield(get_tree().create_timer(0.4), "timeout")
	animPlayer.play("attack")
	yield(animPlayer, "animation_finished")
	if afflicted:
		get_afflicted()
		yield(animPlayer, "animation_finished")
	emit_signal("end_turn")


func deal_damage() -> void:
	var playerStats = BattleUnits.PlayerStats
	if playerStats != null:
		playerStats.take_damage(damage)


func take_damage(amount) -> void:
	self.hp -= amount
	if is_dead():
		yield(get_tree().create_timer(0.02), "timeout")
		# Drop loot
		if not dodged:
			emit_signal("died", experience, randi() % (max_hp / damage), drop_loot())
		else:
			emit_signal("died", 0, 0, "")
		# Death cry
		if self.name != "Mimic":
			var death_cries_dup = death_cries.duplicate()
			death_cries_dup.shuffle()
			var new_death_cry = death_cries_dup.pop_front()
			get_node(new_death_cry).play()
			yield(get_tree().create_timer(0.01), "timeout")
		else:
			$Audio/ChestBreak.play()
			yield(get_tree().create_timer(0.02), "timeout")
		queue_free()
	else:
		animPlayer.play("shake")


func get_afflicted() -> void:
	if affliction_duration > 0:
		# Affliction effect by type
		match affliction:
			"Poison":
				take_damage(ceil(max_hp * 0.1))
				$Audio/Poison.play()
				print("Affliction will last " + str(affliction_duration) + " turns.")
			
			"Burn":
				take_damage(ceil(max_hp * 0.2))
				$Audio/Flame.play()
				print("Affliction will last " + str(affliction_duration) + " turns.")
			# To add a new affliction just add a new entry with its name and the damage it deals
			# The modulate colour and other parameters has to be taken care of on the Item script
			_:
				return
		# Count down the duration so it eventually fades away
		affliction_duration -= 1
	else:
		# Once the duration hits zero, reset its values to normal
		afflicted = false
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		emit_signal("end_turn")


func is_dead() -> bool:
	return hp <= 0


func drop_loot() -> String:
	var loot_dup = loot.duplicate()
	loot_dup.shuffle()
	var new_loot = loot_dup.pop_front()
	return new_loot


func display_info(source) -> void:
	emit_signal("description_changed", source.retrieve_info())


func _on_InspectButton_pressed() -> void:
	pass
