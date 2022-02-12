extends Node2D

signal shopped(item, price)
signal description_changed


func _on_Button_item_bought(item: String, price: int) -> void:
	hide()
	emit_signal("shopped", item, price)
	$Audio/Purchase.play()
	yield($Audio/Purchase, "finished")
	queue_free()


func _on_Exit_pressed() -> void:
	hide()
	emit_signal("shopped")
	$Audio/Exit.play()
	yield($Audio/Exit, "finished")
	queue_free()


func _on_Button_description_changed(description: String) -> void:
	emit_signal("description_changed", description)
