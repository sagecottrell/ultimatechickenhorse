extends Node

signal c_on_player_setup(pid: int, json: String)

signal s_on_file_press_send(fp: String)
signal on_recieve_scene_text(node: String)
signal on_change_scene(node: BaseScene)

## when the user selects "connect", this signal is emitted to tell things that we are now a client
signal on_self_is_client()

## when the user selects "host", this signal is emitted to tell things that we are now a host
signal on_self_is_server()

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

## when the local player gets hurt
signal on_hurt(amount: int)

## show a countdown in the middle of the screen. will be called multiple times
## length is the maximum mount of time to display this text. must greater than zero. newer countdowns will hide this early
## final=true for the last part of the countdown (usually a "GO!" or something)
signal on_countdown(display: String, length: float, final: bool)

## when the server wants to switch to a camera
## pid 1 to switch level cameras, otherwise to get player cameras
## for players, increase=true to get fp, false to get freecam
## for level cameras, increase to move to next, otherwise prev
signal on_cam_switch(pid: int, increase: bool)

## let the clients know that the server is planning on changing the level
signal on_server_changing_level()

@rpc("any_peer")
func c_player_setup(json: String):
	var pid = multiplayer.get_remote_sender_id()
	c_on_player_setup.emit(pid, json)

func s_file_press_send(fp: String):
	s_on_file_press_send.emit(fp)

@rpc("call_local")
func recieve_scene_text(node: String):
	on_recieve_scene_text.emit(node)
	
func change_scene(node: BaseScene):
	on_change_scene.emit(node)

func self_is_client():
	on_self_is_client.emit()

func self_is_server():
	on_self_is_server.emit()

func local_win():
	on_local_win.emit()

@rpc("any_peer")
func client_won():
	on_client_won.emit(multiplayer.get_remote_sender_id())

@rpc("call_local")
func any_win(pid: int, place: String):
	on_any_win.emit(pid, place)

func unstuck():
	on_unstuck.emit()

func die():
	on_die.emit()

func hurt(amount: int = 1):
	on_hurt.emit(amount)

@rpc("call_local")
func countdown(display: String, length: float, final: bool):
	on_countdown.emit(display, length, final)

func cam_switch(pid: int, increase: bool):
	on_cam_switch.emit(pid, increase)

@rpc("call_local")
func server_changing_level():
	on_server_changing_level.emit()
