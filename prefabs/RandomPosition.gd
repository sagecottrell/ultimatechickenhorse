class_name RandomPosition extends Node3D

## if all targets should be moved to the same place, or different places
@export var all_same_pos : bool = false
## how often to move targets to random positions. zero for never
@export var interval_seconds : float = 0
## on ready, move all targets to random spots
@export var init : bool = true
## all the nodes to move
@export var targets : Array[Node3D] = []
## apply rotation
@export var apply_rotation : bool = false

# children should all be Marker3D

var time : float = 0

func _ready():
	if init or interval_seconds <= 0:
		move_targets()
		
func _process(delta: float) -> void:
	if interval_seconds > 0:
		time += delta
		if time >= interval_seconds:
			time -= interval_seconds
			move_targets()

func _filtermarker(node: Node):
	return node is Marker3D

func move_targets():
	var markers = get_children().filter(_filtermarker)
	if all_same_pos:
		var r: Marker3D = markers.pick_random()
		for target in targets:
			target.global_position = r.global_position
			if apply_rotation:
				target.global_rotation = r.global_rotation
	else:
		for target in targets:
			var r: Marker3D = markers.pick_random()
			target.global_position = r.global_position
			if apply_rotation:
				target.global_rotation = r.global_rotation
