# res://src/scenes/gamification/coupon_game.gd
# ---------------------------------------------------------------------------
# Laboratorio 6 — Máquina de Estado Finito (FSM) aplicada al minijuego
# "Taller de Repuestos".
#
# Estados:
#   PLAYING -> el jugador puede moverse y recolectar. Estado inicial.
#   WON     -> se alcanzó la meta de repuestos. Estado terminal.
#   LOST    -> se superó el límite de repuestos generados. Estado terminal.
#
# Transiciones permitidas:
#   PLAYING -> WON
#   PLAYING -> LOST
#   (WON y LOST son terminales: no permiten ninguna transición de salida)
#
# Todo cambio de estado pasa por change_state(), la única función que
# decide si una transición es válida.
# ---------------------------------------------------------------------------
extends Node2D

enum GameState { PLAYING, WON, LOST }

@export var target_items: int = 8
@export var max_spawned_items: int = 20
@export var coupon_value: int = 50000
@export var coupon_minimum_value: int = 300000

@onready var objective: Label = $CanvasLayer/Objective
@onready var result_panel: Control = $CanvasLayer/ResultPanel
@onready var result_label: Label = $CanvasLayer/ResultPanel/ResultLabel
@onready var btn_result_volver: Button = $CanvasLayer/ResultPanel/BtnResultVolver

var current_state: GameState = GameState.PLAYING
var current_spawned_items: int = 0
var collected_items: int = 0

func _ready() -> void:
	var spawners: Array = get_tree().get_nodes_in_group("spawner")
	for spawn: Node in spawners:
		spawn.spawned_item.connect(_on_item_spawned)

	$Player.collected_food.connect(_on_player_collected_food)
	_actualizar_objetivo()

# ---------------------------------------------------------------------------
# Entradas que PUEDEN pedir un cambio de estado (no lo hacen directamente)
# ---------------------------------------------------------------------------

func _on_item_spawned() -> void:
	if current_state != GameState.PLAYING:
		return
	current_spawned_items += 1
	if current_spawned_items > max_spawned_items:
		change_state(GameState.LOST)

func _on_player_collected_food() -> void:
	if current_state != GameState.PLAYING:
		return
	collected_items += 1
	_actualizar_objetivo()
	if collected_items >= target_items:
		change_state(GameState.WON)

# ---------------------------------------------------------------------------
# Función central de la FSM — único lugar donde "current_state" cambia
# ---------------------------------------------------------------------------

func change_state(new_state: GameState) -> void:
	if not _is_transition_allowed(current_state, new_state):
		push_warning("CouponGame: transición inválida %s -> %s, ignorada" % [
			GameState.keys()[current_state], GameState.keys()[new_state]
		])
		return

	current_state = new_state

	match new_state:
		GameState.WON:
			_enter_won()
		GameState.LOST:
			_enter_lost()

func _is_transition_allowed(from: GameState, to: GameState) -> bool:
	match from:
		GameState.PLAYING:
			return to == GameState.WON or to == GameState.LOST
		GameState.WON, GameState.LOST:
			return false
	return false

# ---------------------------------------------------------------------------
# Comportamiento propio de CADA estado
# ---------------------------------------------------------------------------

func _enter_won() -> void:
	_detener_minijuego()

	var coupon: Dictionary = {
		"value": coupon_value,
		"minimum_purchase": coupon_minimum_value,
	}
	EventBus.coupon_obtained.emit(coupon)

	result_label.text = "¡Cupón obtenido: $%d!" % coupon_value
	_reproducir_animacion_resultado()

func _enter_lost() -> void:
	_detener_minijuego()
	result_label.text = "No obtuviste el cupón. Se cayeron demasiados repuestos."
	_reproducir_animacion_resultado()

func _detener_minijuego() -> void:
	var spawners: Array = get_tree().get_nodes_in_group("spawner")
	for spawn: Node in spawners:
		spawn.queue_free()
	$Player.queue_free()

# ---------------------------------------------------------------------------
# Animación Tween asociada a la TRANSICIÓN (no al estado en sí)
# ---------------------------------------------------------------------------

func _reproducir_animacion_resultado() -> void:
	result_panel.pivot_offset = result_panel.size / 2.0
	result_panel.scale = Vector2(0.3, 0.3)
	result_panel.modulate.a = 0.0
	result_panel.show()

	btn_result_volver.disabled = true

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(result_panel, "scale", Vector2(1.0, 1.0), 0.4)
	tween.parallel().tween_property(result_panel, "modulate:a", 1.0, 0.4)
	tween.tween_callback(_on_result_animation_finished)

func _on_result_animation_finished() -> void:
	btn_result_volver.disabled = false

func _actualizar_objetivo() -> void:
	objective.text = "Repuestos: %d / %d" % [collected_items, target_items]
