class_name PlayerVisualRoot
extends Node3D

@export var color_meshes: Array[MeshInstance3D]

@export var player_color: Color:
	set(value):
		player_color = value
		if is_node_ready():
			apply_color()
	get:
		return player_color

func _ready():
	apply_color()

func apply_color():
	for mesh in color_meshes:
		_apply_color(mesh)

func _apply_color(mesh: MeshInstance3D):
	var mat: StandardMaterial3D = mesh.get_active_material(0).duplicate()
	mat.albedo_color = player_color
	mesh.set_surface_override_material(0, mat)
