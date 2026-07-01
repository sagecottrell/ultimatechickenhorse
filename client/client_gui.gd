class_name ClientGUI
extends CanvasLayer

@onready var levelswitch = $levelswitch
@onready var waitingroom: Control = $waitingroom
@onready var ingame: Control = $ingame
@onready var countdownlabel = $ingame/countdownDisplay
@onready var urdead = $ingame/urdead
@onready var respawn_timer_display = %RespawnTimerDisplay

func _ready() -> void:
	levelswitch.visible = false
	waitingroom.visible = false
	ingame.visible = false
	
	urdead.visible = false
	SignalBus.on_countdown.connect(_on_countdown)
	SignalBus.on_respawn_timer.connect(_on_respawn_timer)
	SignalBus.on_die.connect(on_playerdead)
	SignalBus.on_respawn.connect(on_playerlive)

func on_waiting_room():
	levelswitch.visible = false
	waitingroom.visible = true
	ingame.visible = false

func on_ingame():
	levelswitch.visible = false
	waitingroom.visible = false
	ingame.visible = true

func on_levelswitch():
	levelswitch.visible = true
	waitingroom.visible = false
	ingame.visible = false

# ============================================================================
# countdown
# ============================================================================


var countdown_tween: Tween
func _on_countdown(display: String, length: float, _final: bool):
	countdownlabel.visible = true
	countdownlabel.text = display
	if countdown_tween:
		countdown_tween.kill()
	countdown_tween = create_tween()
	countdown_tween.tween_interval(length)
	countdown_tween.tween_callback(_on_countdown_finish)

func _on_countdown_finish():
	countdownlabel.visible = false

# ============================================================================
# player death
# ============================================================================

func on_playerdead():
	urdead.visible = true

func on_playerlive():
	urdead.visible = false

func _on_respawn_timer(left: float, max_time: float):
	respawn_timer_display.max_value = max_time * 100
	respawn_timer_display.value = (max_time - left) * 100
