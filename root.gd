extends Node3D

@export var root: PackedScene

func _ready() -> void:
	pass



func pack_and_send(node: Node3D):
	var scene = PackedScene.new()
	scene.pack(node)
	send_bytes.rpc(var_to_bytes_with_objects(scene))

@rpc()
func send_bytes(bytes: PackedByteArray):
	change_scene(bytes_to_var_with_objects(bytes))

func change_scene(scene: PackedScene):
	var world = $World
	for child in world.get_children():
		world.remove_child(child)
		child.queue_free()
	
	world.add_child(scene.instantiate())


func _on_multiplayer_on_client() -> void:
	pass # Replace with function body.

func _on_client_connect(_id: int):
	pack_and_send($World.get_child(0))

func _on_multiplayer_on_host() -> void:
	# send_bytes.rpc(var_to_bytes_with_objects(root))
	$World.add_child(root.instantiate())
	multiplayer.peer_connected.connect(_on_client_connect)
