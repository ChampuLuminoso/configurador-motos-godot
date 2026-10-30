# res://src/scenes/gamification/belt_part.gd
# Un repuesto que se desliza por la cinta transportadora, de izquierda a
# derecha, hasta que el jugador le hace clic para "tomarlo" (held = true,
# coupon_game.gd lo toma desde ahí y lo mueve con el mouse) o hasta que
# llega al final de la cinta sin ser tomado (left_belt).
#
# A diferencia del repuesto "que caía" del diseño anterior, esto ya no
# usa física (RigidBody2D): es un Area2D que solo se mueve en línea
# recta y detecta clics con su propia señal input_event.
class_name BeltPart
extends Area2D

signal picked_up(part: BeltPart)
signal left_belt(part: BeltPart)

var part_data: PartData
var held: bool = false

@export var speed: float = 140.0
@export var despawn_x: float = 1220.0

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	input_event.connect(_on_input_event)
	if part_data != null:
		_aplicar_part_data()

func _process(delta: float) -> void:
	if held:
		return
	position.x += speed * delta
	if position.x >= despawn_x:
		left_belt.emit(self)
		queue_free()

func set_part(data: PartData) -> void:
	part_data = data
	if is_node_ready():
		_aplicar_part_data()

func _aplicar_part_data() -> void:
	if sprite and part_data and part_data.texture:
		sprite.texture = part_data.texture

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if held:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		picked_up.emit(self)
