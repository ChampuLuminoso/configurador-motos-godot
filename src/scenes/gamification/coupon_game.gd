# res://src/scenes/gamification/coupon_game.gd
# ---------------------------------------------------------------------------
# Máquina de Estado Finito (FSM) del minijuego "Taller de Repuestos".
#
# Modalidad: cinta transportadora + canastas. Los repuestos se deslizan
# por una cinta de izquierda a derecha. El jugador hace clic sobre uno
# para tomarlo (queda "en la mano", siguiendo al cursor) y luego hace
# clic en la canasta correcta para clasificarlo:
#   - Repuestos buenos (GOOD) van a la canasta de su subsistema (Motor
#     o Transmisión).
#   - Repuestos dañados (DAMAGED) o chatarra (JUNK) siempre van a la
#     canasta de Descarte, sin importar a qué se parezcan.
# Si un repuesto llega al final de la cinta sin ser tomado, también
# cuenta como error (se "perdió" esa pieza).
#
# Estados:
#   PLAYING -> el jugador puede tomar y clasificar. Estado inicial.
#   WON     -> se alcanzó la meta de aciertos. Estado terminal.
#   LOST    -> se acumularon demasiados errores. Estado terminal.
#
# Transiciones permitidas:
#   PLAYING -> WON
#   PLAYING -> LOST
#   (WON y LOST son terminales: no permiten ninguna transición de salida)
#
# Todo cambio de estado pasa por change_state(), la única función que
# decide si una transición es válida — mismo patrón del Laboratorio 6.
# ---------------------------------------------------------------------------
extends Node2D

enum GameState { PLAYING, WON, LOST }
enum Zone { MOTOR, TRANSMISION, DESCARTE }

const BeltPartScene: PackedScene = preload("res://src/scenes/gamification/belt_part.tscn")
const PART_DATABASE: PartDatabase = preload("res://src/data/repuestos/part_database.tres")
const CURSOR_TEXTURE: Texture2D = preload("res://src/assets/ui/cursor/cursor_chico.png")

# El puntito amarillo dibujado sobre el ícono del cursor queda justo en
# este píxel de la textura — ahí es exactamente donde registra el clic
# (Input.set_custom_mouse_cursor usa "hotspot" para eso), no en una
# esquina del dibujo ni debajo de los pies.
const CURSOR_HOTSPOT: Vector2 = Vector2(36, 6)

const PART_WEIGHT_GOOD: int = 3
const PART_WEIGHT_OTHER: int = 1

@export var target_aciertos: int = 10
@export var max_errores: int = 5
@export var coupon_value: int = 50000
@export var coupon_minimum_value: int = 300000
@export var spawn_interval: float = 1.4
@export var belt_speed: float = 140.0
@export var belt_y: float = 214.0
@export var belt_start_x: float = -40.0
@export var belt_despawn_x: float = 1220.0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var basket_motor: RepairBasket = $BasketMotor
@onready var basket_transmision: RepairBasket = $BasketTransmision
@onready var basket_descarte: RepairBasket = $BasketDescarte
@onready var aciertos_label: Label = $CanvasLayer/Marcador/MarcadorBox/AciertosLabel
@onready var errores_label: Label = $CanvasLayer/Marcador/MarcadorBox/ErroresLabel
@onready var result_panel: Control = $CanvasLayer/ResultPanel
@onready var result_label: Label = $CanvasLayer/ResultPanel/ResultLabel
@onready var btn_result_volver: Button = $CanvasLayer/ResultPanel/BtnResultVolver

var current_state: GameState = GameState.PLAYING
var aciertos: int = 0
var errores: int = 0
var weighted_parts: Array[PartData] = []
var held_part: BeltPart = null

func _ready() -> void:
	get_viewport().physics_object_picking = true
	Input.set_custom_mouse_cursor(CURSOR_TEXTURE, Input.CURSOR_ARROW, CURSOR_HOTSPOT)

	_construir_pool_ponderado()
	_actualizar_marcador()

	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

	for basket: RepairBasket in [basket_motor, basket_transmision, basket_descarte]:
		basket.basket_clicked.connect(_on_basket_clicked)

func _exit_tree() -> void:
	# Restaura el cursor normal del sistema para el resto de la app
	# (menús, configurador, etc.) al salir de este minijuego.
	Input.set_custom_mouse_cursor(null)

func _process(_delta: float) -> void:
	if held_part != null:
		held_part.global_position = get_global_mouse_position() + Vector2(0, 42)

# ---------------------------------------------------------------------------
# Generación de repuestos en la cinta
# ---------------------------------------------------------------------------

func _construir_pool_ponderado() -> void:
	for part: PartData in PART_DATABASE.parts:
		var weight: int = PART_WEIGHT_GOOD if part.category == PartData.Category.GOOD else PART_WEIGHT_OTHER
		for i in range(weight):
			weighted_parts.append(part)

func _elegir_parte() -> PartData:
	return weighted_parts[randi() % weighted_parts.size()]

func _on_spawn_timer_timeout() -> void:
	if current_state != GameState.PLAYING:
		return
	var item: BeltPart = BeltPartScene.instantiate()
	add_child(item)
	item.global_position = Vector2(belt_start_x, belt_y)
	item.speed = belt_speed
	item.despawn_x = belt_despawn_x
	item.set_part(_elegir_parte())
	item.picked_up.connect(_on_part_picked_up)
	item.left_belt.connect(_on_part_left_belt)

# ---------------------------------------------------------------------------
# Entradas que PUEDEN pedir un cambio de estado (no lo hacen directamente)
# ---------------------------------------------------------------------------

func _on_part_picked_up(part: BeltPart) -> void:
	if current_state != GameState.PLAYING or held_part != null:
		return
	held_part = part
	part.held = true

func _on_part_left_belt(part: BeltPart) -> void:
	if current_state != GameState.PLAYING or part == held_part:
		return
	errores += 1
	_actualizar_marcador()
	if errores >= max_errores:
		change_state(GameState.LOST)

func _on_basket_clicked(zone_id: String) -> void:
	if current_state != GameState.PLAYING or held_part == null:
		return

	var part: PartData = held_part.part_data
	var zona_clic: Zone = _zone_from_id(zone_id)
	var zona_correcta: Zone = _zona_correcta(part)

	held_part.queue_free()
	held_part = null

	if zona_clic == zona_correcta:
		aciertos += 1
		_actualizar_marcador()
		if aciertos >= target_aciertos:
			change_state(GameState.WON)
	else:
		errores += 1
		_actualizar_marcador()
		if errores >= max_errores:
			change_state(GameState.LOST)

# ---------------------------------------------------------------------------
# Reglas de clasificación
# ---------------------------------------------------------------------------

func _zone_from_id(zone_id: String) -> Zone:
	match zone_id:
		"motor":
			return Zone.MOTOR
		"transmision":
			return Zone.TRANSMISION
	return Zone.DESCARTE

func _zona_correcta(part: PartData) -> Zone:
	if part.category != PartData.Category.GOOD:
		return Zone.DESCARTE
	match part.subsystem:
		PartData.Subsystem.MOTOR:
			return Zone.MOTOR
		PartData.Subsystem.TRANSMISION:
			return Zone.TRANSMISION
	return Zone.DESCARTE

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

	result_label.text = "¡Repuestos bien clasificados! Cupón obtenido: $%d" % coupon_value
	_reproducir_animacion_resultado()

func _enter_lost() -> void:
	_detener_minijuego()
	result_label.text = "Se te acumularon demasiados repuestos mal clasificados o perdidos en la cinta."
	_reproducir_animacion_resultado()

func _detener_minijuego() -> void:
	spawn_timer.stop()
	if held_part != null:
		held_part.queue_free()
		held_part = null
	for part: Node in get_tree().get_nodes_in_group("belt_part"):
		part.queue_free()

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

# ---------------------------------------------------------------------------
# Marcador en pantalla
# ---------------------------------------------------------------------------

func _actualizar_marcador() -> void:
	aciertos_label.text = "Aciertos: %d / %d" % [aciertos, target_aciertos]
	errores_label.text = "Errores: %d / %d" % [errores, max_errores]
