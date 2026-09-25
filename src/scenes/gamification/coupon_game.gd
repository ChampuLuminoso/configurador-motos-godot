# res://src/scenes/gamification/coupon_game.gd
# Controlador raíz del minijuego "Taller de Repuestos". Centraliza las
# condiciones de victoria y derrota. Al ganar, emite el cupón por el
# EventBus — no conoce la pantalla de compra ni a GlobalManager.
extends Node2D

@export var target_items: int = 8
@export var max_spawned_items: int = 14
@export var coupon_value: int = 50000
@export var coupon_minimum_value: int = 300000

@onready var objective: Label = $CanvasLayer/Objective
@onready var result_panel: Control = $CanvasLayer/ResultPanel
@onready var result_label: Label = $CanvasLayer/ResultPanel/ResultLabel

var current_spawned_items: int = 0
var collected_items: int = 0
var game_finished: bool = false

func _ready() -> void:
	var spawners: Array = get_tree().get_nodes_in_group("spawner")
	for spawn: Node in spawners:
		spawn.spawned_item.connect(_on_item_spawned)

	$Player.collected_food.connect(_on_player_collected_food)
	_actualizar_objetivo()

func _on_item_spawned() -> void:
	current_spawned_items += 1
	if current_spawned_items > max_spawned_items:
		lose_game()

func _on_player_collected_food() -> void:
	collected_items += 1
	_actualizar_objetivo()
	if collected_items >= target_items:
		win_game()

func _actualizar_objetivo() -> void:
	objective.text = "Repuestos: %d / %d" % [collected_items, target_items]

func win_game() -> void:
	if game_finished:
		return
	clean_game()

	var coupon: Dictionary = {
		"value": coupon_value,
		"minimum_purchase": coupon_minimum_value,
	}
	EventBus.coupon_obtained.emit(coupon)

	result_label.text = "¡Cupón obtenido: $%d!" % coupon_value
	result_panel.show()

func lose_game() -> void:
	if game_finished:
		return
	clean_game()

	result_label.text = "No obtuviste el cupón. Se cayeron demasiados repuestos."
	result_panel.show()

func clean_game() -> void:
	if game_finished:
		return

	game_finished = true
	var spawners: Array = get_tree().get_nodes_in_group("spawner")
	for spawn: Node in spawners:
		spawn.queue_free()
	$Player.queue_free()
