# res://tests/test_global_manager_cupones.gd
# Laboratorio 10 — Parte 3 (guiada): prueba unitaria automatizada con
# GdUnit4 sobre la regla real de selección de cupones, caso UNI-01 de
# doc/qa/casos_prueba_lab10.md.
#
# GlobalManager extiende Node, así que se puede instanciar para probar
# get_best_coupon() de forma aislada. Pero su _ready() también conecta
# señales del EventBus y carga cupones persistidos desde disco — para
# que esas dependencias no afecten la prueba, la instancia NUNCA se
# agrega al árbol de escenas (su _ready() nunca se ejecuta) y la
# colección de cupones se prepara a mano en cada caso.
#
# IMPORTANTE: before_test()/after_test() (no before()/after()) son los
# que GdUnit4 corre ANTES y DESPUÉS DE CADA caso. before()/after() solo
# corren una vez para toda la suite — si se usan por error, la misma
# instancia de manager se reutiliza entre pruebas y el estado de una
# prueba contamina la siguiente.
class_name TestGlobalManagerCupones
extends GdUnitTestSuite

const GlobalManagerScript = preload("res://src/core/global_manager.gd")

# Tipado explícito (no "var manager" a secas): así "manager.coupons = [...]"
# es una asignación estáticamente tipada y GDScript puede convertir el
# array literal a Array[Dictionary]. Sin el tipo, esa misma línea pasa
# por el setter dinámico de Object y falla con "Invalid assignment of
# property or key 'coupons' with value of type 'Array'".
var manager: GlobalManagerScript

func before_test() -> void:
	manager = GlobalManagerScript.new()

func after_test() -> void:
	manager.free()

# Caso 1 — Cupón válido: hay un solo cupón y la compra alcanza su mínimo.
func test_returns_coupon_when_subtotal_is_sufficient() -> void:
	manager.coupons = [
		{"value": 2000, "minimum_purchase": 10000}
	]
	var result = manager.get_best_coupon(12000)
	assert_object(result).is_equal({
		"value": 2000,
		"minimum_purchase": 10000
	})

# Caso 2 — Compra inferior al mínimo: ningún cupón aplica.
func test_returns_empty_dictionary_when_no_coupon_is_valid() -> void:
	manager.coupons = [
		{"value": 2000, "minimum_purchase": 10000}
	]
	var result = manager.get_best_coupon(9999)
	assert_bool(result.is_empty()).is_true()

# Caso 3 — Varios cupones válidos: se elige el de mayor valor.
func test_returns_coupon_with_highest_value() -> void:
	manager.coupons = [
		{"value": 1000, "minimum_purchase": 5000},
		{"value": 3000, "minimum_purchase": 10000}
	]
	var result = manager.get_best_coupon(12000)
	assert_object(result).is_equal({
		"value": 3000,
		"minimum_purchase": 10000
	})
