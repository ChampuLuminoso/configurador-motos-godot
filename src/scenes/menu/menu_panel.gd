# res://src/scenes/menu/menu_panel.gd
# Solo te encargas de cerrar la app y de la animación de entrada. La
# navegación hacia las otras pantallas la resuelven los botones ButtonNav
# que ya están configurados en la escena, no este script.
extends Control

@onready var btn_salir: Button = $VBoxMenu/BtnSalir

func _ready() -> void:
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	_reproducir_fade_in()

func _reproducir_fade_in() -> void:
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)

func _on_btn_salir_pressed() -> void:
	get_tree().quit()
