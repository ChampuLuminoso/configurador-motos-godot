# res://src/scenes/purchase_invoice/purchase_invoice.gd
# Pantalla de resumen y confirmación de la compra de accesorios. Lee el
# estado ya calculado en GlobalManager y le pide el mejor cupón
# disponible para el subtotal actual.
extends Control

@onready var lbl_subtotal: Label = $VBoxContainer/LblSubtotal
@onready var lbl_coupon: Label = $VBoxContainer/LblCoupon
@onready var lbl_total: Label = $VBoxContainer/LblTotal
@onready var btn_confirm: Button = $VBoxContainer/BtnConfirm

var applied_coupon: Dictionary = {}

func _ready() -> void:
	btn_confirm.pressed.connect(_on_confirm)
	_update_invoice()

func _on_confirm() -> void:
	if not applied_coupon.is_empty():
		GlobalManager.remove_coupon(applied_coupon)
		applied_coupon = {}
	lbl_coupon.text = "Compra confirmada. ¡Gracias por elegirnos!"
	btn_confirm.disabled = true

func _update_invoice() -> void:
	var color_actual: String = GlobalManager.color_actual

	var detalle_items: String = ""
	for accessory_id: String in GlobalManager.accesorios_activos:
		var precio: int = GlobalManager.precios_accesorios.get(accessory_id, 0)
		detalle_items += "ACCESORIO: %s    $%d\n" % [accessory_id, precio]

	if detalle_items.is_empty():
		detalle_items = "(sin accesorios seleccionados)\n"

	var subtotal: int = GlobalManager.precio_total

	lbl_subtotal.text = (
		"COLOR ELEGIDO: %s\n"
		+ "%s"
		+ "--------------------------------\n"
		+ "Subtotal: $%d"
	) % [color_actual, detalle_items, subtotal]

	applied_coupon = GlobalManager.get_best_coupon(subtotal)

	var discount: int = 0
	if not applied_coupon.is_empty():
		discount = applied_coupon["value"]

	var final_total: int = max(subtotal - discount, 0)

	if discount > 0:
		lbl_coupon.text = "Descuento aplicado por cupón: $%d" % discount
	else:
		lbl_coupon.text = "Sin cupón aplicable a esta compra."

	lbl_total.text = "TOTAL: $%d" % final_total
