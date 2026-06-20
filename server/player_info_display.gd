class_name PlayerInfoDisplay extends Control

func set_info(info: PlayerInfo):
	%place.visible = false
	%label.text = "Connected Player: [color=#%s]%s[/color]" % [info.color.to_html(false), info.name]

func set_place(n):
	%place.visible = true
	var d = {n: str(n) + "th", 1: "1st", 2: "2nd", 3: "3rd"}
	%place.text = d[n]

func hide_place():
	%place.visible = false

func _on_switch_cam_button_pressed() -> void:
	SignalBus.cam_switch(name.to_int(), false)
