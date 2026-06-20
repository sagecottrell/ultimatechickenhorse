extends Node3D

func _ready() -> void:
	SignalBus.on_change_scene.connect(change_scene)

func change_scene(scene: BaseScene):
	var world = $World
	for child in world.get_children():
		world.remove_child(child)
		child.queue_free()
	world.add_child(scene)
