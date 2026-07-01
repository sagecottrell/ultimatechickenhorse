extends HBoxContainer

@onready var prefab = $prefab

func _enter_tree() -> void:
	SignalBus.on_client_player_hp.connect(_on_player_hp)

func _ready():
	prefab.visible = false

func _on_player_hp(max_hp: int, amount: int):
	var m = get_child_count() - 1
	if max_hp < m:
		for i in range(m, max_hp, -1):
			var child = get_child(i)
			_fall_tween(child).tween_callback(child.queue_free)
	elif max_hp > m:
		for i in range(m, max_hp):
			var new = prefab.duplicate()
			new.visible = true
			add_child(new)
	
	for i in range(1, max_hp + 1):
		var child = get_child(i)
		var full: Control = child.get_child(1)
		if i > amount:
			_fall_tween(full)
		elif i <= amount:
			full.offset_transform_position = Vector2.ZERO
			full.offset_transform_rotation = 0
			full.modulate.a = 1

func _fall_tween(node: Control) -> Tween:
	var tween = node.create_tween()
	tween.tween_property(node, "offset_transform_position", Vector2(0, 50), 1)
	tween.parallel().tween_property(node, "offset_transform_rotation", 1.7, 1)
	tween.parallel().tween_property(node, "modulate:a", 0, 1)
	return tween
