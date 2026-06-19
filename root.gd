class_name Root
extends Node3D


static var PlayerIds: Dictionary[int, PlayerInfo] = {}
static var PlayerList: Array[int] = []

static var rankings: Array[int] = []

func _ready() -> void:
	$ServerGUI.visible = false
	$ClientGUI.visible = false
	$LevelSwitch.visible = false
	multiplayer.server_relay = true


func pack_and_send(fp: String):
	clear_places()
	
	var file = FileAccess.open(fp, FileAccess.READ)
	pre_level_push.rpc()
	
	await get_tree().create_timer(0.5).timeout
	
	push_scene_to_all.rpc(file.get_as_text())
	
	var world = Str2Node.tscn_string_to_node(file.get_as_text())
	change_scene(world)


@rpc()
func pre_level_push():
	$LevelSwitch.visible = true


@rpc()
func push_scene_to_all(txt: String):
	change_scene(Str2Node.tscn_string_to_node(txt))
	$LevelSwitch.visible = false


func change_scene(scene: BaseScene):
	var world = $World
	for child in world.get_children():
		world.remove_child(child)
		child.queue_free()
	scene.on_win.connect(func(): player_win.rpc_id(1))
	world.add_child(scene)

func _on_multiplayer_on_client() -> void:
	# on the client side, when the client starts up
	$ClientGUI.visible = true
	$DirectoryWatcher.queue_free()
	
	var info: PlayerInfo = $Multiplayer.get_playerinfo()
	send_player_info.rpc(info.to_json())


@rpc("any_peer")
func send_player_info(json: String):
	# The server knows who sent the input.
	var sender_id = multiplayer.get_remote_sender_id()
	var info: PlayerInfo = PlayerInfo.from_json(json)
	PlayerIds[sender_id] = info
	PlayerList.append(sender_id)
	
	var display: PlayerInfoDisplay = preload("res://server/PlayerInfoDisplay.tscn").instantiate()
	display.set_info(info)
	display.name = str(sender_id)
	%PlayerList.add_child(display)


@rpc("any_peer")
func player_win():
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id in rankings:
		return
	var index = rankings.size()
	rankings.append(sender_id)
	var child: PlayerInfoDisplay = %PlayerList.find_child(str(sender_id), false, false)
	child.set_place(index + 1)
	

func _on_client_connect(id: int):
	prints("client connected:", id)


func _on_multiplayer_on_host() -> void:
	# on the server side, when the server starts up
	$ServerGUI.visible = true
	multiplayer.peer_connected.connect(_on_client_connect)


func clear_places():
	rankings.clear()
	for child in %PlayerList.get_children():
		if child is PlayerInfoDisplay:
			child.hide_place()
