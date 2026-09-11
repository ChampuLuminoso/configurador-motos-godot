# res://src/core/main_app.gd
# Este es tu orquestador: la única escena que decide qué pantalla mostrar
# y cuándo destruir la anterior. También lleva el historial de a dónde
# has navegado, como una pila.
extends Control

const MENU_SCENE_PATH: String = "res://src/scenes/menu/menu_panel.tscn"

@onready var scene_container: Control = $SceneContainer

var current_scene: Node = null
var navigation_history: Array[String] = []

func _ready() -> void:
	EventBus.navigation_requested.connect(_on_navigation_requested)
	_on_navigation_requested(MENU_SCENE_PATH, false)

func _on_navigation_requested(target_scene: String, discard_previous: bool) -> void:
	# Si vienes de un botón de "volver", quitas del historial en vez de
	# apilar una entrada nueva.
	if discard_previous:
		if not navigation_history.is_empty():
			navigation_history.pop_back()
	else:
		navigation_history.append(target_scene)

	print("MainApp: navigation_history -> ", navigation_history)

	if current_scene:
		current_scene.queue_free()
		current_scene = null

	var new_scene_resource: PackedScene = load(target_scene) as PackedScene
	if new_scene_resource == null:
		push_error("MainApp: no fue posible cargar la escena: %s" % target_scene)
		return

	var new_scene_instance: Node = new_scene_resource.instantiate()
	scene_container.add_child(new_scene_instance)
	current_scene = new_scene_instance
