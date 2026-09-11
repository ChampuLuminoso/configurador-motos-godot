# res://src/scenes/menu/menu_panel.gd
extends Control

const CONFIGURATOR_SCENE_PATH: String = "res://src/scenes/configurator/configurator_panel.tscn"
const CREDITS_SCENE_PATH: String = "res://src/scenes/credits/credits_panel.tscn"

@onready var btn_configurar: Button = $VBoxMenu/BtnConfigurar
@onready var btn_creditos: Button = $VBoxMenu/BtnCreditos
@onready var btn_salir: Button = $VBoxMenu/BtnSalir

func _ready() -> void:
	btn_configurar.pressed.connect(_on_navigate_pressed.bind(CONFIGURATOR_SCENE_PATH))
	btn_creditos.pressed.connect(_on_navigate_pressed.bind(CREDITS_SCENE_PATH))
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	_reproducir_fade_in()

func _reproducir_fade_in() -> void:
	# 1. Arrancamos invisible (transparencia en 0).
	modulate.a = 0.0
	# 2. Creamos un Tween: un "animador" temporal que Godot destruye solo
	#    quiere que la propiedad "modulate:a" (el canal alfa del color)
	#    llegue a 1.0 (totalmente visible) en 0.4 segundos.
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)

func _on_navigate_pressed(target_scene_path: String) -> void:
	EventBus.navigation_requested.emit(target_scene_path)

func _on_btn_salir_pressed() -> void:
	get_tree().quit()
