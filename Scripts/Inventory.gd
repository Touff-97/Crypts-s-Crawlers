extends Control


func _on_Back_pressed() -> void:
	visible = !visible


func _on_sound_fx(sound: String) -> void:
	match sound:
		"Bomb":
			$Audio/Bomb.play()
		
		"Potion":
			$Audio/Potion.play()
		
		"Flame":
			$Audio/Flame.play()
		
		"Poison":
			$Audio/Poison.play()
