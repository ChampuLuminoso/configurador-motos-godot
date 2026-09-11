# res://src/core/main_app.gd
extends Control

const MENU_SCENE_PATH: String = "res://src/scenes/menu/menu_panel.tscn"

@onready var scene_container: Control = $SceneContainer

var current_scene: Node = null

func _ready() -> void:
	EventBus.navigation_requested.connect(_on_navigation_requested)
	_on_navigation_requested(MENU_SCENE_PATH)

func _on_navigation_requested(target_scene_path: String) -> void:
	if current_scene:
		current_scene.queue_free()
		current_scene = null

	var new_scene_resource: PackedScene = load(target_scene_path) as PackedScene
	if new_scene_resource == null:
		push_error("MainApp: no fue posible cargar la escena: %s" % target_scene_path)
		return

	var new_scene_instance: Node = new_scene_resource.instantiate()
	scene_container.add_child(new_scene_instance)
	current_scene = new_scene_instance
