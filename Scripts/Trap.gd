extends Node2D

const BattleUnits = preload("res://Resources/BattleUnits.tres")

export(Array, String) var traps = []

onready var sprite = $Sprite
onready var animPlayer = $AnimationPlayer

signal description_changed
signal trapped

func _ready() -> void:
	randomize()
	yield(get_tree().create_timer(0.5), "timeout")
	var traps_dup = traps.duplicate()
	traps_dup.shuffle()
	var new_trap = traps_dup.pop_front()
	sprite.texture = load("res://Assets/Sprites/Traps/" + new_trap + ".svg")
	trigger_trap(new_trap)


func trigger_trap(type: String) -> void:
	var playerStats = BattleUnits.PlayerStats
	
	match type:
		"cobweb":
			playerStats.ap = randi() % 2 + 1
			playerStats.mp -= randi() % 9 + 1
			$Audio/Cobweb.play()
			emit_signal("description_changed", "A sticky cobweb sticks to you.")
		
		"explosion":
			playerStats.hp -= playerStats.max_hp / 3
			$Audio/Explosion.play()
			emit_signal("description_changed", "Boom!")
		
		"snare":
			playerStats.hp -= playerStats.max_hp / 5
			playerStats.mp -= randi() % 9 + 1
			$Audio/Snare.play()
			emit_signal("description_changed", "Its teeth dig into your ankles.")
		
		"spikes":
			playerStats.hp -= playerStats.max_hp / 5
			playerStats.ap -= 1
			emit_signal("description_changed", "Your feet are punctured!")
			$Audio/Spikes.play()
		
		_:
			return
	
	animPlayer.play("blink")
	yield(animPlayer, "animation_finished")
	yield(get_tree().create_timer(0.5), "timeout")
	emit_signal("trapped")
	queue_free()
