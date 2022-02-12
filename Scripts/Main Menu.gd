extends Control

const Battle = preload("res://Scenes/Battle.tscn")
const Settings = preload("res://Scenes/Settings.tscn")

onready var mainMenu = $Background
onready var animPlayer = $AnimationPlayer
onready var parent = $Instance
onready var settings = $Settings
onready var music = $Audio/Music
onready var btn_press = $Audio/ButtonPressed

var Scene : PackedScene
var end : bool = false


# Virtual
func _process(_delta: float) -> void:
	var buttons = get_tree().get_nodes_in_group("Button")
	for b in buttons:
		if b.is_pressed() and not b.is_in_group("Exception"):
			b.pressed = false
			btn_press.play()


# Signals
func _on_Continue_pressed() -> void:
	# If there's a save file, enable the option to continue it.
	pass


func _on_NewGame_pressed() -> void:
	# Start a new game regardless of save files.
	var new_battle = Battle.instance()
	animPlayer.play("fade")
	yield(get_tree().create_timer(0.4), "timeout")
	parent.add_child(new_battle)
	new_battle.connect("end", self, "_on_Battle_end")


func _on_Settings_pressed() -> void:
	Scene = null
	animPlayer.play("fade")
	yield(get_tree().create_timer(0.4), "timeout")
	settings.show()


func _on_Quit_pressed() -> void:
	get_tree().quit()


func _on_Music_finished() -> void:
	if not end:
		music.play()


func _on_Battle_end() -> void:
	print("Battle ended")
	end = true
	music.stop()


func _on_Touff_pressed() -> void:
	$Audio/LinkPressed.play()
	OS.shell_open("https://www.youtube.com/channel/UCWPOkDtRTf_BDrCNvQ3CMhw")


func _on_Heartbeast_pressed() -> void:
	$Audio/LinkPressed.play()
	OS.shell_open("https://www.youtube.com/c/uheartbeast")
