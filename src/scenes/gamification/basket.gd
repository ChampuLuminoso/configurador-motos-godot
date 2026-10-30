# res://src/scenes/gamification/basket.gd
# Canasta clickeable del taller. zone_id identifica la categoría que
# acepta ("motor" / "transmision" / "descarte") y se configura desde el
# Inspector en cada instancia de basket.tscn dentro de coupon_game.tscn,
# para no acoplar este script al enum interno de coupon_game.gd.
#
# La zona clickeable es grande (ocupa un tercio del ancho de la pantalla,
# pegada abajo) para que sea fácil soltar la pieza ahí — no hay que
# apuntarle justo al ícono de la caja.
class_name RepairBasket
extends Area2D

signal basket_clicked(zone_id: String)

@export var zone_id: String = "motor"

func _ready() -> void:
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		basket_clicked.emit(zone_id)
