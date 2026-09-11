# res://src/scenes/credits/credits_panel.gd
# Este script solo existe por la animación de entrada. El botón de volver
# ya no necesita código: es un ButtonNav configurado directo en la escena.
extends Control

func _ready() -> void:
	_reproducir_fade_in()

func _reproducir_fade_in() -> void:
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.25)
