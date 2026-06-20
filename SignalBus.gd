extends Node

signal on_recieve_scene(node: BaseScene)
signal on_change_scene(node: BaseScene)
signal on_pre_level_push()

## when the user selects "connect", this signal is emitted to tell things that we are now a client
signal on_self_is_client()

## when the user selects "host", this signal is emitted to tell things that we are now a host
signal on_self_is_server()

## a client setup
signal on_client_setup(info: PlayerInfo)

## when the local player first reaches the goal
signal on_local_win()

## when a client submits a win
signal on_client_won(pid: int)

## when any connected player reaches the goal, including the local player
signal on_any_win(pid: int, place: String)

## when the local player wants to get unstuck
signal on_unstuck()

## when the local player should die
signal on_die()

## when the server wants to switch to a camera
## pid 1 to switch level cameras, otherwise to get player cameras
## for players, increase=true to get fp, false to get freecam
## for level cameras, increase to move to next, otherwise prev
signal on_cam_switch(pid: int, increase: bool)

func recieve_scene(node: BaseScene):
	on_recieve_scene.emit(node)
func change_scene(node: BaseScene):
	on_change_scene.emit(node)
func pre_level_push():
	on_pre_level_push.emit()

func self_is_client():
	on_self_is_client.emit()

func self_is_server():
	on_self_is_server.emit()

func client_setup(info: PlayerInfo):
	on_client_setup.emit(info)

func local_win():
	on_local_win.emit()

func client_won(pid: int):
	on_client_won.emit(pid)

func any_win(pid: int, place: String):
	on_any_win.emit(pid, place)

func unstuck():
	on_unstuck.emit()

func die():
	on_die.emit()

func cam_switch(pid: int, increase: bool):
	on_cam_switch.emit(pid, increase)
