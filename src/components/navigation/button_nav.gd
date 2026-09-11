# res://src/components/navigation/button_nav.gd
# Un botón que ya sabe navegar por sí solo. Lo configuras desde el
# Inspector (a dónde ir, y si es un botón de "volver") y no necesitas
# escribir ni una línea de código en la escena donde lo uses.
extends Button
class_name ButtonNav

@export_file("*.tscn") var target_scene: String = ""
@export var discard_previous: bool = false

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if target_scene.is_empty():
		push_warning("ButtonNav: no se configuró 'target_scene' en el Inspector.")
		return
	EventBus.navigation_requested.emit(target_scene, discard_previous)
