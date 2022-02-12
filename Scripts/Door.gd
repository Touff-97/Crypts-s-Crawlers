extends Node2D

enum doorType {
	ENTRANCE,
	ENEMY,
	SHOP,
	TREASURE,
	TRAP,
	BOSS,
	NEXT_FLOOR,
}

export(doorType) var door_type = doorType.ENTRANCE

signal description_changed
signal door_entered


func display_info(source) -> void:
	emit_signal("description_changed", source.retrieve_info())


func _on_InspectButton_pressed() -> void:
	pass


func _on_EnterRoom_pressed() -> void:
	print("Enter room button pressed!")
	emit_signal("door_entered", door_type)
	queue_free()
