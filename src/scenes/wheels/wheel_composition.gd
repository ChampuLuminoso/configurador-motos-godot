# res://src/scenes/wheels/wheel_composition.gd
# Laboratorio 9 — Parte 4/5/6 adaptadas: selección y animación de las
# dos ruedas. Cada rueda (delantera/trasera) guarda su propio rin
# elegido de forma independiente, igual que cada mitad de la pizza en
# la guía guarda su propio ingrediente.
class_name WheelComposition
extends Control

enum Wheel { FRONT, REAR }

var selected_wheel: Wheel = Wheel.FRONT
var front_rim: RimData
var rear_rim: RimData

@onready var front_texture: TextureRect = $FrontWheel
@onready var rear_texture: TextureRect = $RearWheel
@onready var front_button: Button = $FrontWheel/Button
@onready var rear_button: Button = $RearWheel/Button
@onready var front_selection: ColorRect = $FrontWheel/Selection
@onready var rear_selection: ColorRect = $RearWheel/Selection

func _ready() -> void:
	front_button.pressed.connect(_on_front_pressed)
	rear_button.pressed.connect(_on_rear_pressed)
	update_selection_visual()

func _on_front_pressed() -> void:
	selected_wheel = Wheel.FRONT
	update_selection_visual()

func _on_rear_pressed() -> void:
	selected_wheel = Wheel.REAR
	update_selection_visual()

# Recibe el RimData elegido desde la lista de la izquierda y lo aplica
# a la rueda que esté activa en ese momento.
func _on_rim_selected(rim: RimData) -> void:
	if rim == null:
		return

	var wheel_name: String = "front" if selected_wheel == Wheel.FRONT else "rear"
	EventBus.rim_selected.emit(rim.id, wheel_name)

	match selected_wheel:
		Wheel.FRONT:
			front_rim = rim
			front_texture.texture = rim.texture
		Wheel.REAR:
			rear_rim = rim
			rear_texture.texture = rim.texture

	animate_wheel_update()

## Restaura un rin ya guardado en GlobalManager (por ejemplo, al volver
## a esta pantalla) sin reemitir la señal ni repetir la animación.
func aplicar_rim_guardado(rim: RimData, wheel: String) -> void:
	if rim == null:
		return
	match wheel:
		"front":
			front_rim = rim
			front_texture.texture = rim.texture
		"rear":
			rear_rim = rim
			rear_texture.texture = rim.texture

# --- Retroalimentación visual (Laboratorio 9, Parte 5) ---
func update_selection_visual() -> void:
	var selected_selection: ColorRect = (
		front_selection if selected_wheel == Wheel.FRONT else rear_selection
	)
	var other_selection: ColorRect = (
		rear_selection if selected_wheel == Wheel.FRONT else front_selection
	)

	var tween: Tween = create_tween()
	tween.set_parallel(true)

	# Destello de color: aparece y queda muy transparente, marcando la
	# rueda activa.
	tween.tween_property(selected_selection, "color", Color(1.0, 0.55, 0.15, 0.35), 0.10)
	tween.tween_property(
		selected_selection, "color", Color(1.0, 0.55, 0.15, 0.08), 0.20
	).set_delay(0.10)

	# La otra rueda pierde su indicador.
	tween.tween_property(other_selection, "color", Color(1.0, 1.0, 1.0, 0.0), 0.12)

# --- Animación al cambiar de rin (Laboratorio 9, Parte 6) ---
func animate_wheel_update() -> void:
	var target: TextureRect = front_texture if selected_wheel == Wheel.FRONT else rear_texture
	target.scale = Vector2(0.85, 0.85)
	target.modulate = Color(1.0, 1.0, 1.0, 0.0)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(target, "scale", Vector2.ONE, 0.18)
	tween.tween_property(target, "modulate", Color.WHITE, 0.18)
