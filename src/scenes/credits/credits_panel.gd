# res://src/scenes/credits/credits_panel.gd
extends Control

const MENU_SCENE_PATH: String = "res://src/scenes/menu/menu_panel.tscn"

@onready var btn_volver: Button = $VBoxCreditos/BtnVolver

func _ready() -> void:
	print("Panel de créditos cargado.")
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	_reproducir_fade_in()

func _reproducir_fade_in() -> void:
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)

func _on_btn_volver_pressed() -> void:
	EventBus.navigation_requested.emit(MENU_SCENE_PATH)
