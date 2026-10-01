# res://src/core/global_manager.gd
# Aquí guardas y calculas todo lo relacionado a la configuración de la
# moto. No tocas ningún botón ni Label desde este archivo: solo escuchas
# lo que te avisan por el EventBus y devuelves el resultado por ahí mismo.
extends Node

var precios_accesorios: Dictionary = {
	"Parabrisas": 150000,
	"Alforjas": 300000,
	"Escape Deportivo": 450000,
}

var color_actual: String = "Sin seleccionar"
var accesorios_activos: Array[String] = []
var precio_total: int = 0

# Cupones (Laboratorio 5). Ejemplo: {"value": 50000, "minimum_purchase": 300000}
var coupons: Array[Dictionary] = []

# Laboratorio 7 — ruta del archivo de persistencia.
const SAVE_PATH: String = "user://save_data.json"

func _ready() -> void:
	EventBus.color_selected.connect(_on_color_selected)
	EventBus.accessory_toggled.connect(_on_accessory_toggled)
	EventBus.coupon_obtained.connect(_on_coupon_obtained)
	load_coupons()

func _on_color_selected(color_name: String) -> void:
	color_actual = color_name
	EventBus.color_changed.emit(color_actual)

func _on_accessory_toggled(accessory_id: String, active: bool) -> void:
	if not precios_accesorios.has(accessory_id):
		push_warning("GlobalManager: accesorio desconocido -> %s" % accessory_id)
		return

	if active:
		if not accesorios_activos.has(accessory_id):
			accesorios_activos.append(accessory_id)
	else:
		accesorios_activos.erase(accessory_id)

	_recalcular_total()

func _recalcular_total() -> void:
	var total: int = 0
	for accessory_id: String in accesorios_activos:
		if precios_accesorios.has(accessory_id):
			total += precios_accesorios[accessory_id]

	precio_total = total
	EventBus.total_changed.emit(precio_total)

# --- Cupones (Laboratorio 5) ---

func _on_coupon_obtained(coupon: Dictionary) -> void:
	coupons.append(coupon)
	print("GlobalManager: cupón recibido -> ", coupon)
	save_coupons()

func get_best_coupon(subtotal: int) -> Dictionary:
	var best_coupon: Dictionary = {}
	for coupon: Dictionary in coupons:
		if subtotal >= coupon["minimum_purchase"]:
			if best_coupon.is_empty():
				best_coupon = coupon
			elif coupon["value"] > best_coupon["value"]:
				best_coupon = coupon
	return best_coupon

func remove_coupon(coupon: Dictionary) -> void:
	if coupon in coupons:
		coupons.erase(coupon)
		save_coupons()

# --- Persistencia (Laboratorio 7) ---

func save_coupons() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("GlobalManager: no se pudo guardar en %s (error %s)" % [
			SAVE_PATH, FileAccess.get_open_error()
		])
		return

	var data: Dictionary = {"coupons": coupons}
	file.store_string(JSON.stringify(data))
	file.close()

func load_coupons() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("GlobalManager: no se pudo leer %s (error %s)" % [
			SAVE_PATH, FileAccess.get_open_error()
		])
		return

	var content: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("coupons"):
		push_warning("GlobalManager: save_data.json con formato inesperado, se ignora.")
		return

	coupons.clear()
	for raw_coupon: Variant in parsed["coupons"]:
		if typeof(raw_coupon) == TYPE_DICTIONARY:
			coupons.append(raw_coupon as Dictionary)
