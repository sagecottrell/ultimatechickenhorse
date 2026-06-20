# multiplayer.gd
class_name MultiplayerInfo
extends Node

const PORT = 9999

signal on_host()
signal on_client(info: PlayerInfo)

func _ready():
	# Start paused
	get_tree().paused = true
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false

	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_pressed.call_deferred()


func _on_host_pressed():
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	host_start_game()

func _on_connect_pressed():
	if not %PlayerName.text:
		OS.alert("must enter a name")
		return
	
	# Start as client.
	var txt : String = %Remote.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	prints("connecting to", txt)
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(txt, PORT)
	if err != Error.OK:
		OS.alert("client create: " + String(err))
		return
	
	$UI.process_mode = Node.PROCESS_MODE_DISABLED
		
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(client_start_game)


func host_start_game():
	# Hide the UI and unpause to start the game.
	prints("hosting", multiplayer.multiplayer_peer.get_connection_status())
	$UI.hide()
	get_tree().paused = false
	on_host.emit()

func client_start_game():
	print("client connected")
	# Hide the UI and unpause to start the game.
	$UI.hide()
	get_tree().paused = false
	on_client.emit(get_playerinfo())

func get_playerinfo() -> PlayerInfo:
	var color: Color = %PlayerColor.color
	return PlayerInfo.new(%PlayerName.text, Color.from_hsv(color.h, 1, 1))
