extends Node3D

func _ready() -> void:
	$ServerGUI.visible = false
	$ClientGUI.visible = false

func pack_and_send(fp: String):
	var file = FileAccess.open(fp, FileAccess.READ)
	send_bytes.rpc(file.get_as_text())

@rpc()
func send_bytes(txt: String):
	change_scene(tscn_string_to_node(txt))

func change_scene(scene: Node):
	var world = $World
	for child in world.get_children():
		world.remove_child(child)
		child.queue_free()
	
	world.add_child(scene)


func _on_multiplayer_on_client() -> void:
	# on the client side, when the client starts up
	$ClientGUI.visible = true
	$DirectoryWatcher.queue_free()

func _on_client_connect(id: int):
	prints("client connected:", id)

func _on_multiplayer_on_host() -> void:
	# on the server side, when the server starts up
	$ServerGUI.visible = true
	multiplayer.peer_connected.connect(_on_client_connect)

func _on_file_send_pressed(fp: String):
	var scene = ResourceLoader.load(fp) as PackedScene
	change_scene(scene.instantiate())
	pack_and_send(fp)

func tscn_string_to_node(tscn_text: String) -> Node:
	var temp_path = "user://temp_runtime_scene.tscn"
	
	# 1. Save the string content into a temporary file
	var file = FileAccess.open(temp_path, FileAccess.WRITE)
	if file:
		file.store_string(tscn_text)
		file.close()
	else:
		push_error("Failed to write temporary TSCN text file.")
		return null
		
	# 2. Load the file path into a PackedScene resource
	var packed_scene = ResourceLoader.load(temp_path) as PackedScene
	
	# 3. Safely delete the temporary file from disk
	DirAccess.remove_absolute(temp_path)
	
	# 4. Return the instantiated node tree
	if packed_scene:
		return packed_scene.instantiate()
	else:
		push_error("Failed to parse and load the TSCN text string.")
		return null


func _on_directory_watcher_files_modified(files: PackedStringArray) -> void:
	prints("modified", files)
	var fl = %FileList
	for file_path in files:
		var n = str(hash(file_path))
		var child = fl.find_child(n, false, false)
		if child is FileSelector:
			child.update()
		else:
			_create_fileselector(fl, file_path)

func _on_directory_watcher_files_deleted(files: PackedStringArray) -> void:
	prints("deleted", files)
	var fl = %FileList
	for file_path in files:
		var n = str(hash(file_path))
		var child = fl.find_child(n, false, false)
		if child is FileSelector:
			child.queue_free()


func _on_directory_watcher_files_created(files: PackedStringArray) -> void:
	prints("created", files)
	var fl = %FileList
	for file_path in files:\
		_create_fileselector(fl, file_path)

func _create_fileselector(fl: Node, fp: String):
	var child: FileSelector = preload("res://server/FileSelector.tscn").instantiate()
	child.name = str(hash(fp))
	child.file_path = fp
	fl.add_child(child)
	child.pressed.connect(_on_file_send_pressed)
	
