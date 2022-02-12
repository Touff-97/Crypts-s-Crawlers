extends Panel

const BattleUnits = preload("res://Resources/BattleUnits.tres")

onready var hp_label : Label = $HBox/HPLabel
onready var hp_info : Control = $HBox/HPLabel/InputInfo
onready var hp_anim : AnimationPlayer = $HBox/HPLabel/AnimationPlayer

onready var mp_label : Label = $HBox/MPLabel
onready var mp_info : Control = $HBox/MPLabel/InputInfo
onready var mp_anim : AnimationPlayer = $HBox/MPLabel/AnimationPlayer

onready var ap_label : Label = $HBox/APLabel
onready var ap_info : Control = $HBox/APLabel/InputInfo
onready var ap_anim : AnimationPlayer = $HBox/APLabel/AnimationPlayer

signal description_changed


func _ready() -> void:
	var playerStats = BattleUnits.PlayerStats
	hp_label.text = "HP\n" + str(playerStats.hp) + "/" + str(playerStats.max_hp)


func _on_PlayerStats_hp_changed(value) -> void:
	hp_label.text = "HP\n" + str(value) + "/" + str(BattleUnits.PlayerStats.max_hp)
	if BattleUnits.PlayerStats.hp < BattleUnits.PlayerStats.max_hp:
		hp_anim.play("hp_blink")


func _on_PlayerStats_mp_changed(value) -> void:
	mp_label.text = "MP\n" + str(value) + "/10"
	if BattleUnits.PlayerStats.mp < BattleUnits.PlayerStats.max_mp:
		mp_anim.play("mp_blink")


func _on_PlayerStats_ap_changed(value) -> void:
	ap_label.text = "AP\n" + str(value) + "/3"
	if BattleUnits.PlayerStats.ap < BattleUnits.PlayerStats.max_ap:
		ap_anim.play("ap_blink")


func _on_HPInspectButton_pressed() -> void:
	emit_signal("description_changed", hp_info.retrieve_info())


func _on_APInspectButton_pressed() -> void:
	emit_signal("description_changed", ap_info.retrieve_info())


func _on_MPInspectButton_pressed() -> void:
	emit_signal("description_changed", mp_info.retrieve_info())
