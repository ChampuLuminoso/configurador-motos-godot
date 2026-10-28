# res://tests/test_global_manager_accesorios.gd
# Laboratorio 10 — Parte 4 (reto autónomo): prueba unitaria automatizada
# sobre _on_accessory_toggled() + _recalcular_total(), caso UNI-02 de
# doc/qa/casos_prueba_lab10.md. Es una función real distinta a la de
# cupones usada en la Parte 3.
#
# Misma estrategia que en el caso guiado: la instancia de GlobalManager
# no se agrega al árbol, así que _ready() nunca conecta el EventBus.
# Por eso las pruebas llaman directamente a _on_accessory_toggled() en
# vez de emitir la señal — un emit no llegaría a esta instancia huérfana.
class_name TestGlobalManagerAccesorios
extends GdUnitTestSuite

const GlobalManagerScript = preload("res://src/core/global_manager.gd")

var manager

func before() -> void:
	manager = GlobalManagerScript.new()

func after() -> void:
	manager.free()

# Caso positivo — un accesorio válido activado suma su precio.
func test_total_increases_when_valid_accessory_activated() -> void:
	manager._on_accessory_toggled("Parabrisas", true)
	assert_int(manager.precio_total).is_equal(150000)

# Caso positivo compuesto — dos accesorios activados se suman entre sí.
func test_total_sums_multiple_active_accessories() -> void:
	manager._on_accessory_toggled("Parabrisas", true)
	manager._on_accessory_toggled("Alforjas", true)
	assert_int(manager.precio_total).is_equal(450000)

# Caso límite — desactivar un accesorio ya activo lo resta del total.
func test_total_returns_to_zero_when_accessory_deactivated() -> void:
	manager._on_accessory_toggled("Parabrisas", true)
	manager._on_accessory_toggled("Parabrisas", false)
	assert_int(manager.precio_total).is_equal(0)

# Caso negativo — un id de accesorio que no existe en precios_accesorios
# se ignora: no se agrega a accesorios_activos ni afecta el total.
func test_unknown_accessory_is_ignored() -> void:
	manager._on_accessory_toggled("Sidecar", true)
	assert_int(manager.precio_total).is_equal(0)
	assert_bool(manager.accesorios_activos.has("Sidecar")).is_false()
