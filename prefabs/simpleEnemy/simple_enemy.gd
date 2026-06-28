extends CharacterBody3D

@onready var aggro = $Aggro
@onready var lookbeforeleap = $RayCast3D

enum State {
	idle=0,
	jump=1,
	turning=2, # when deciding where to jump next
	dead=3,
}

@export var state: State = State.idle

@export_category("Movement")
@export var jumping_power: float = 10
@export var continue_turning_time: float = 0.5 ## time to continue turning after discovering a valid position
## time spent in idle after jumping, before turning to jump again
@export var resting_time: float = 1

@export_category("Damage")
@export var player_damage: int = 1

const FRICTION_GROUPS = {"icy": 0.93}

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var target: Player = null
var rest_time: float = 0
var turning_direction = 1
var continue_turning_time_current: float = 0
var turning_time: float = 0
var current_surface_friction: float = 1

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	match state:
		State.idle:
			rest_time += delta
			if rest_time >= resting_time:
				rest_time = 0
				state = State.turning
				turning_direction = [-1, 1].pick_random() * (randf() + 0.5)
		State.turning:
			if lookbeforeleap.is_colliding():
				turning_time += delta
				rotate_y(turning_direction * delta)
				if turning_time >= continue_turning_time_current:
					turning_time = 0
					continue_turning_time_current = continue_turning_time
					var d: Vector3 = lookbeforeleap.get_collision_point() - global_position
					var g = get_gravity().normalized()
					velocity += (-g + d.normalized()) * 4
			else:
				continue_turning_time_current += delta / 2
				turning_time = 0
				rotate_y(turning_direction * delta)
		State.jump:
			if is_on_floor():
				state = State.idle

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# Add the gravity.
	velocity += get_gravity() * delta
	move_and_slide()
	if is_on_floor():
		var friction = Physics.get_friction(self, FRICTION_GROUPS)
		velocity -= velocity * pow(friction, 1/delta)
	else:
		state = State.jump

func kill():
	state = State.dead

func _on_aggro_body_entered(body: Node3D) -> void:
	if body is Player and body.is_multiplayer_authority():
		target = body


func _on_aggro_body_exited(body: Node3D) -> void:
	if body == target:
		target = null


func _on_hurtbox_body_entered(body: Node3D) -> void:
	if body is Player and body.is_multiplayer_authority():
		SignalBus.hurt(player_damage)


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body is Player and body.is_multiplayer_authority():
		kill()


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if not Engine.is_editor_hint() and anim_name == "die":
		queue_free()
