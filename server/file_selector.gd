class_name FileSelector extends PanelContainer

@export var file_path: String
var status : int = 0

signal pressed(file_path: String)

func _ready() -> void:
	display()
	
func display():
	if is_node_ready():
		%Label.text = "%s %s" % [file_path, fmt_status()]

func _on_send_pressed() -> void:
	pressed.emit(file_path)

func update():
	status = 1
	display()

func fmt_status():
	match status:
		0:
			return "[color=green]NEW![/color]"
		1:
			return "[color=orange]Updated[/color]"
		_:
			return ""
