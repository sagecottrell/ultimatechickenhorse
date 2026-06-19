extends PathFollow3D

signal on_complete()

@export var units_per_second: float = 1
@export var active: bool = false

var parent: Path3D
var length: float

func _ready():
	parent = get_parent()
	length = parent.curve.get_baked_length()

func start():
	active = true
	
func stop():
	active = false

func _physics_process(delta: float) -> void:
	if not active:
		return
	
	progress += delta * units_per_second
	if progress >= length:
		on_complete.emit()
		if not loop:
			active = false
