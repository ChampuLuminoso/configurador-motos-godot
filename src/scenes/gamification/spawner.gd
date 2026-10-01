# res://src/scenes/gamification/spawner.gd
# Genera instancias del repuesto a intervalos regulares, hasta un máximo
# de objetos activos a la vez.
extends Node2D
signal spawned_item

@export var max_active_items: int = 5
@export var spawn_interval: float = 1.0
@export var collectable_scene: PackedScene
@export var use_parabola: bool = false
@export var parabola_horizontal_range: float = 150.0
@export var parabola_vertical_impulse: float = -180.0

@onready var timer: Timer = $Timer

var active_items: int = 0

func _ready() -> void:
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_spawn_timer_timeout)
	timer.start()

func _on_spawn_timer_timeout() -> void:
	if active_items >= max_active_items:
		return

	spawned_item.emit()
	var spawn_position: Vector2 = global_position

	if use_parabola:
		var horizontal_impulse: float = randf_range(-parabola_horizontal_range, parabola_horizontal_range)
		spawn_from_side(spawn_position, Vector2(horizontal_impulse, parabola_vertical_impulse))
	else:
		spawn_item(spawn_position)

func spawn_item(spawn_position: Vector2) -> void:
	var item: RigidBody2D = collectable_scene.instantiate()
	item.global_position = spawn_position
	item.apply_central_impulse(Vector2(0, -100))
	get_parent().add_child(item)
	active_items += 1
	item.tree_exiting.connect(_on_spawned_item_removed)

func spawn_from_side(spawn_position: Vector2, impulse: Vector2) -> void:
	var item: RigidBody2D = collectable_scene.instantiate()
	item.global_position = spawn_position
	get_parent().add_child(item)
	item.apply_central_impulse(impulse)
	active_items += 1
	item.tree_exiting.connect(_on_spawned_item_removed)

func _on_spawned_item_removed() -> void:
	# Sin este contador bajando, active_items llega al máximo y el
	# spawner se queda "lleno" para siempre, aunque el jugador ya haya
	# recolectado o el objeto ya haya caído fuera del área de juego.
	active_items -= 1
