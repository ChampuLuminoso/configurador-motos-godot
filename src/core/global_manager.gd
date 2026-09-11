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

func _ready() -> void:
	EventBus.color_selected.connect(_on_color_selected)
	EventBus.accessory_toggled.connect(_on_accessory_toggled)

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
