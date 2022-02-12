extends Node2D


func _ready() -> void:
	$Sprite.play()


func _on_Sprite_animation_finished() -> void:
	queue_free()
