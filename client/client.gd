class_name Client
extends Node

func _ready() -> void:
	$ClientGUI.visible = false
	$LevelSwitch.visible = false
	SignalBus.on_self_is_server.connect(_on_self_is_server)

func _on_multiplayer_on_client(info: PlayerInfo) -> void:
	# on the client side, when the client starts up
	$ClientGUI.visible = true
	
	SignalBus.on_local_win.connect(player_win.rpc_id.bind(1))
	SignalBus.on_recieve_scene.connect(_on_recieve_scene)
	SignalBus.on_pre_level_push.connect(pre_level_push.rpc)
	multiplayer.server_disconnected.connect(_on_server_disconnect)
	
	print('on client')
	SignalBus.client_setup(info)

func _on_server_disconnect():
	print('server disconnect')

@rpc("any_peer")
func player_win():
	var sender_id = multiplayer.get_remote_sender_id()
	SignalBus.client_won(sender_id)

@rpc()
func pre_level_push():
	$LevelSwitch.visible = true

func _on_recieve_scene(node: BaseScene):
	SignalBus.change_scene(node)
	$LevelSwitch.visible = false
	$ClientGUI.visible = false

func _on_self_is_server():
	pass
