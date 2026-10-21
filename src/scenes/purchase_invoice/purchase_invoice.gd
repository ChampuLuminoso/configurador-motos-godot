# res://src/scenes/purchase_invoice/purchase_invoice.gd
# Pantalla de resumen y confirmación de la compra de accesorios. Lee el
# estado ya calculado en GlobalManager y le pide el mejor cupón
# disponible para el subtotal actual.
extends Control

@onready var lbl_subtotal: Label = $VBoxContainer/LblSubtotal
@onready var lbl_coupon: Label = $VBoxContainer/LblCoupon
@onready var lbl_total: Label = $VBoxContainer/LblTotal
@onready var btn_confirm: Button = $VBoxContainer/BtnConfirm
@onready var pop_up_confirm: Panel = $PurchaseSuccessPopup
@onready var btn_cerrar_popup: Button = $PurchaseSuccessPopup/VBoxContainer/BtnCerrarPopup

var applied_coupon: Dictionary = {}

func _ready() -> void:
	btn_confirm.pressed.connect(_on_confirm)
	btn_cerrar_popup.pressed.connect(_on_cerrar_popup)
	_update_invoice()

func _on_confirm() -> void:
	if not applied_coupon.is_empty():
		GlobalManager.remove_coupon(applied_coupon)
		applied_coupon = {}
	lbl_coupon.text = "Compra confirmada. ¡Gracias por elegirnos!"
	btn_confirm.disabled = true
	pop_up_confirm.show()

func _on_cerrar_popup() -> void:
	pop_up_confirm.hide()

func _update_invoice() -> void:
	var color_actual: String = GlobalManager.color_actual

	var detalle_items: String = ""
	for accessory_id: String in GlobalManager.accesorios_activos:
		var precio: int = GlobalManager.precios_accesorios.get(accessory_id, 0)
		detalle_items += "ACCESORIO: %s    $%d\n" % [accessory_id, precio]

	if detalle_items.is_empty():
		detalle_items = "(sin accesorios seleccionados)\n"

	# Laboratorio 9 — rines elegidos desde el catálogo dinámico.
	var detalle_rines: String = _detalle_rines()

	var subtotal: int = GlobalManager.precio_total + GlobalManager.moto_rines_total

	lbl_subtotal.text = (
		"COLOR ELEGIDO: %s\n"
		+ "%s"
		+ "%s"
		+ "--------------------------------\n"
		+ "Subtotal: $%d"
	) % [color_actual, detalle_items, detalle_rines, subtotal]

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

# Laboratorio 9 — arma el detalle de rines (delantero/trasero) a partir
# del catálogo de GlobalManager.rims, consultando el id guardado en
# moto_rines.
func _detalle_rines() -> String:
	var etiquetas: Dictionary = {"front": "Delantero", "rear": "Trasero"}
	var detalle: String = ""

	for wheel: String in ["front", "rear"]:
		var rim_id: String = GlobalManager.moto_rines.get(wheel, "")
		if rim_id.is_empty():
			continue
		for rim: RimData in GlobalManager.rims:
			if rim.id == rim_id:
				detalle += "RIN %s: %s    $%d\n" % [etiquetas[wheel], rim.display_name, rim.price]
				break

	return detalle
