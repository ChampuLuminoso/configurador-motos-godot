# res://src/components/interactive/hover_button.gd
# ---------------------------------------------------------------------------
# COMPONENTE REUTILIZABLE: HoverButton — Laboratorio 5
# ---------------------------------------------------------------------------
# Aquí resuelves la interacción con el entorno: cuando el mouse entra o
# sale del área del botón, lo iluminas o lo devuelves a la normalidad.
# Lo asignas como script a cualquier Button existente (no reemplaza su
# lógica de clic, solo le agrega feedback visual), así evitas repetir
# este mismo código en cada botón que quieras que reaccione al mouse.
# ---------------------------------------------------------------------------
extends Button
class_name HoverButton

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.18, 1.18, 1.18, 1.0), 0.12)

func _on_mouse_exited() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.12)
