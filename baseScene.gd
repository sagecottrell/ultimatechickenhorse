class_name BaseScene
extends Node3D

func _enter_tree():
	$MultiplayerSpawner.spawn_function = spawn_player

func _ready():
	if multiplayer.get_unique_id() == 1:
		spawn_players()
	

func spawn_player(info: Dictionary):
	var spawn: Node3D = get_node(info.at)
	var player_scene = preload("res://prefabs/Player.tscn")
	var player: Player = player_scene.instantiate()
	player.add_to_group("Player")
	player.name = str(info.pid)
	player.global_transform = spawn.global_transform
	player.player_color = info.color
	player.player_name = info.name
	player.spawn_point = spawn
	return player

func spawn_players():
	var spawns: Array[Node3D] = []
	for child in get_children():
		if child is PlayerSpawn:
			spawns.append(child)
	for pair in Zip.zip(spawns, Server.PlayerList, false):
		var spawn: Node = pair[0]
		var player_id: int = pair[1]
		var player_info = Server.PlayerIds[player_id]
		var info = {"at": spawn.get_path(), "pid": player_id, "color": player_info.color, "name": player_info.name}
		$MultiplayerSpawner.spawn(info)


func _on_deathplane_body_entered(body: Node3D) -> void:
	if body is Player:
		body._reset()


func _on_star_collide(player: Player) -> void:
	if player.name.to_int() != multiplayer.get_unique_id():
		return
	$Star.queue_free()
	SignalBus.local_win()
	
