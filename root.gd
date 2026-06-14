extends Node3D

@export var root: PackedScene

func _ready() -> void:
	var b = var_to_bytes_with_objects(root)
	print(b)
	var s = bytes_to_var_with_objects(b)
	print(s)
	
	add_child(s.instantiate())
