@tool
extends Node3D


func _physics_process(delta: float) -> void:
	$MeshInstance3D.rotate_y(delta)
