class_name HealthManager
extends Node

signal on_die()
signal on_hurt(amount: int)
signal current_hp(max: int, amount: int)

@export var invulnerable: bool = false

@export var BaseMaxHP: int = 3
@export var MaxHP: int = 3
@export var CurrentHP: int = 3

func _ready():
	publish_current.call_deferred()
	
func publish_current():
	current_hp.emit(MaxHP, CurrentHP)

func reset():
	MaxHP = BaseMaxHP
	CurrentHP = MaxHP
	publish_current()

func hurt(amount: int = 1):
	if invulnerable:
		return
	CurrentHP -= amount
	on_hurt.emit(amount)
	current_hp.emit(MaxHP, CurrentHP)
	if CurrentHP <= 0:
		CurrentHP = 0
		on_die.emit()
