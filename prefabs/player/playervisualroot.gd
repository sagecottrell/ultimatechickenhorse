class_name PlayerVisualRoot
extends Node3D

@export var color_meshes: Array[MeshInstance3D]
var all_meshes: Array[Node]

@export var player_color: Color:
	set(value):
		player_color = value
		if is_node_ready():
			apply_color()
	get:
		return player_color

func _ready():
	apply_color()
	all_meshes = find_children("", "MeshInstance3D")

func hide_meshes():
	for child in all_meshes:
		if child is MeshInstance3D:
			child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY

func show_meshes():
	for child in all_meshes:
		if child is MeshInstance3D:
			child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

func apply_color():
	for mesh in color_meshes:
		_apply_color(mesh)

func _apply_color(mesh: MeshInstance3D):
	var mat: StandardMaterial3D = mesh.get_active_material(0).duplicate()
	mat.albedo_color = player_color
	mesh.set_surface_override_material(0, mat)
