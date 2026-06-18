extends Node3D

func _enter_tree():
	$MultiplayerSpawner.spawn_function = spawn_player

func _ready():
	if multiplayer.get_unique_id() == 1:
		spawn_players()

func spawn_player(info: Dictionary):
	var spawn: Node3D = get_node(info.at)
	var player_scene = preload("res://prefabs/player/Player.tscn")
	var player: Node3D = player_scene.instantiate()
	player.add_to_group("Player")
	player.name = str(info.pid)
	player.global_transform = spawn.global_transform
	return player

func spawn_players():
	var spawns: Array[Node3D] = []
	for child in get_children():
		if child is PlayerSpawn:
			spawns.append(child)
	for pair in Zip.zip(spawns, Root.PlayerList, false):
		var spawn: Node = pair[0]
		var player_id: int = pair[1]
		var info = {"at": spawn.get_path(), "pid": player_id}
		$MultiplayerSpawner.spawn(info)
