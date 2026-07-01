class_name Player 
extends FPSController3D

@export var first_person: bool = true:
	set(value):
		first_person = value
		if is_node_ready():
			switch_to_fp_or_tp_cam()
	get:
		return first_person
@onready var first_person_cam: PhantomCamera3D = %FirstPersonCamera
@onready var third_person_cam: PhantomCamera3D = %ThirdPersonCamera
@onready var free_cam: PhantomCamera3D = $FreeCam
@onready var win_cam: PhantomCamera3D = $CameraOnWin
@onready var vis_root: PlayerVisualRoot = $PlayerVisualRoot
@onready var hp: HealthManager = $HealthManager

@export var input_back_action_name := "move_backward"
@export var input_forward_action_name := "move_forward"
@export var input_left_action_name := "move_left"
@export var input_right_action_name := "move_right"
@export var input_sprint_action_name := "move_sprint"
@export var input_jump_action_name := "move_jump"
@export var input_crouch_action_name := "move_crouch"

@export var anim_tree: AnimationTree

@export var underwater_env: Environment

@export var player_color: Color

@export var player_name: String

@export var spawn_point: Node3D

@export var invuln_length: float = 1

var movement_locked : bool
var camera_locked : bool
var is_self: bool
enum State {
	idle=0,
	walk=1,
	dead=3,
	swim=5,
	sprint=6,
	win=7,
}

@export_category("State")

@export var crouch: bool:
	set(value):
		crouch = value
		if not is_node_ready():
			return
		anim_tree.set("parameters/BlendCrouch/blend_amount", int(value))
	get:
		return crouch
@export var hurt: bool:
	set(value):
		hurt = value
		if not is_node_ready():
			return
		anim_tree.set("parameters/BlendHurt/blend_amount", int(value))
	get:
		return hurt

@export var state: State = State.idle:
	set(value):
		state = value
		if not is_node_ready():
			return
		anim_tree.set("parameters/state-trans/transition_request", State.find_key(value))
	get:
		return state

func _reset():
	head.actual_rotation.x = 0
	global_transform = spawn_point.global_transform
	velocity = Vector3.ZERO
	state = State.idle
	hp.reset()

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	state = State.idle
	setup()
	is_self = name.to_int() == multiplayer.get_unique_id()
	
	if is_multiplayer_authority():
		SignalBus.on_local_win.connect(on_win)
		SignalBus.on_countdown.connect(on_countdown)
		switch_to_fp_or_tp_cam()
		movement_locked = true  # start locked, the server will send an unlock signal
		
		crouched.connect(func(): crouch = true)
		uncrouched.connect(func(): crouch = false)
		sprinted.connect(func(): state = State.sprint)
		submerged.connect(func(): state = State.swim)
		
		SignalBus.on_hurt.connect(hp.hurt)
		SignalBus.on_die.connect(_on_die)
		SignalBus.on_respawn.connect(_reset)
		hp.on_hurt.connect(_on_hurt)
		hp.on_die.connect(SignalBus.die) ## these signals may seem redundant, but it's important to include the signal bus in the process
		hp.current_hp.connect(SignalBus.client_player_hp)
	else:
		SignalBus.on_cam_switch.connect(on_cam_switch)
	
	vis_root.player_color = player_color
	$Nametag.text = player_name
	$Ranking.text = ""
	
	SignalBus.on_any_win.connect(set_rank)
	
	#emerged.connect(_on_controller_emerged.bind())
	#submerged.connect(_on_controller_subemerged.bind())

func set_rank(pid: int, rank: String):
	if pid != name.to_int():
		return
	$Ranking.text = rank

func _physics_process(delta):
	if not is_multiplayer_authority() or movement_locked:
		return
		
	var is_valid_input := Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	
	if is_valid_input:
		var input_axis = Input.get_vector(input_left_action_name, input_right_action_name, input_back_action_name, input_forward_action_name)
		var input_jump = Input.is_action_just_pressed(input_jump_action_name)
		var input_crouch = Input.is_action_pressed(input_crouch_action_name)
		var input_sprint = Input.is_action_pressed(input_sprint_action_name)
		var input_swim_down = Input.is_action_pressed(input_crouch_action_name)
		var input_swim_up = Input.is_action_pressed(input_jump_action_name)
		
		if input_axis.is_zero_approx():
			if not is_submerged():
				state = State.idle
		elif not input_sprint:
			state = State.walk

		move(delta, input_axis, input_jump, input_crouch, input_sprint, input_swim_down, input_swim_up)
	else:
		# NOTE: It is important to always call move() even if we have no inputs 
		# to process, as we still need to calculate gravity and collisions.
		move(delta)


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
		
	# 1. Capture on click
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()

	# 2. Release on pressing Escape (ui_cancel)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Mouse look (only if the mouse is captured).
	if not camera_locked and event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_head(event.screen_relative)

func on_countdown(_display: String, _length: float, final: bool):
	movement_locked = not final

func disable_cams():
	free_cam.priority = 0
	first_person_cam.priority = 0
	third_person_cam.priority = 0
	win_cam.priority = 0

func switch_to_fp_or_tp_cam():
	if first_person:
		switch_to_first_person()
	else:
		switch_to_third_person()

func switch_to_first_person():
	vis_root.hide_meshes()
	disable_cams()
	first_person_cam.priority = 200
	
func switch_to_third_person():
	vis_root.show_meshes()
	disable_cams()
	third_person_cam.priority = 200

func switch_to_free_cam():
	vis_root.show_meshes()
	disable_cams()
	free_cam.priority = 200

func switch_to_win_cam():
	vis_root.show_meshes()
	disable_cams()
	win_cam.priority = 200


var hurt_timer: SceneTreeTimer
func _on_hurt(_amount: int):
	hurt = true
	if hurt_timer:
		hurt_timer.time_left = invuln_length
		return
	hp.invulnerable = true
	hurt_timer = get_tree().create_timer(invuln_length)
	await hurt_timer.timeout
	hp.invulnerable = false
	hurt = false
	hurt_timer = null

func _on_die():
	if state == State.dead:
		return
	state = State.dead
	movement_locked = true
	var tween = create_tween()
	tween.tween_method(func (v): SignalBus.respawn_timer(v, 2.0), 2.0, 0.0, 2)
	await tween.finished
	movement_locked = false
	SignalBus.respawn()

func on_win():
	switch_to_win_cam()
	camera_locked = true
	movement_locked = true
	head.actual_rotation.x = 0
	head.rotation = Vector3.ZERO
	state = State.win
	await anim_tree.animation_finished
	state = State.idle
	camera_locked = false
	movement_locked = false
	switch_to_fp_or_tp_cam()

func on_cam_switch(pid: int, fp: bool):
	if pid != name.to_int():
		disable_cams()
		return
	if fp:
		switch_to_first_person()
	else:
		switch_to_free_cam()
