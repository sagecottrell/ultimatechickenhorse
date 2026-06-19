extends Node3D

signal collide(player: Player)

@export var enabled : bool = true

# radians per second
@export var rotate_speed : float = 4

func _process(delta: float) -> void:
	if enabled:
		$star.visible = true
		$star.rotate_y(delta * rotate_speed)
	else:
		$star.visible = false

func on_collide(area: Node3D):
	if area is Player and enabled:
		collide.emit(area)
