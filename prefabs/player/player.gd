class_name Player 
extends FPSController3D

@export var input_back_action_name := "move_backward"
@export var input_forward_action_name := "move_forward"
@export var input_left_action_name := "move_left"
@export var input_right_action_name := "move_right"
@export var input_sprint_action_name := "move_sprint"
@export var input_jump_action_name := "move_jump"
@export var input_crouch_action_name := "move_crouch"

@export var anim_tree: AnimationTree

@export var underwater_env: Environment

@export var idling_ground: bool = false:
	set(v):
		if is_node_ready():
			if v and not idling_ground:
				idle()
			elif not v and idling_ground:
				walk()
		idling_ground = v

@export var player_color: Color

@export var player_name: String

@export var spawn_point: Node3D

func _reset():
	head.actual_rotation = Vector3.ZERO
	global_transform = spawn_point.global_transform
	velocity = Vector3.ZERO

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	setup()
	
	if is_multiplayer_authority():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$Head/FirstPersonCamera.priority = 100
	
	$PlayerVisualRoot.player_color = player_color
	$Nametag.text = player_name
	$Ranking.text = ""
	
	#emerged.connect(_on_controller_emerged.bind())
	#submerged.connect(_on_controller_subemerged.bind())

func set_rank(rank: String):
	$Ranking.text = rank

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
		
	var is_valid_input := Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	
	if is_valid_input:
		var input_axis = Input.get_vector(input_left_action_name, input_right_action_name, input_back_action_name, input_forward_action_name)
		var input_jump = Input.is_action_just_pressed(input_jump_action_name)
		var input_crouch = Input.is_action_pressed(input_crouch_action_name)
		var input_sprint = Input.is_action_pressed(input_sprint_action_name)
		var input_swim_down = Input.is_action_pressed(input_crouch_action_name)
		var input_swim_up = Input.is_action_pressed(input_jump_action_name)
		
		if input_axis.is_zero_approx() and not idling_ground:
			idling_ground = true
		elif not input_axis.is_zero_approx() and idling_ground:
			idling_ground = false
		
		move(delta, input_axis, input_jump, input_crouch, input_sprint, input_swim_down, input_swim_up)
	else:
		# NOTE: It is important to always call move() even if we have no inputs 
		# to process, as we still need to calculate gravity and collisions.
		move(delta)


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
		
	# Mouse look (only if the mouse is captured).
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_head(event.screen_relative)

func idle(blendtime: float = 0.3):
	var tween = get_tree().create_tween()
	tween.tween_property(anim_tree, "parameters/Blend2/blend_amount", 0, blendtime)

func walk(blendtime: float = 0.3):
	var tween = get_tree().create_tween()
	tween.tween_property(anim_tree, "parameters/Blend2/blend_amount", 1.0, blendtime)
	
func spin():
	var tween = get_tree().create_tween()
	$Head/ThirdPersonCamera.priority_override = true
	tween.tween_property(self, "rotation", Vector3(0, 720, 0), 0.5)
	get_node(anim_tree.anim_player).play("")

func reset_spin():
	$Head/FirstPersonCamera.priority_override = false
