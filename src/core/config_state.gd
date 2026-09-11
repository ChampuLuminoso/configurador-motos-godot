# res://src/core/config_state.gd
# ---------------------------------------------------------------------------
# CONFIG STATE (Autoload / Singleton) — PIEZA NUEVA respecto al Lab 2.
# ---------------------------------------------------------------------------
# Guarda en memoria la configuración que el usuario va armando (moto elegida,
# color, accesorios y precio total) para que sobreviva aunque el usuario
# navegue entre escenas usando el EventBus.
#
# Es un Autoload como EventBus, pero con una responsabilidad distinta:
# EventBus transporta eventos puntuales (algo "pasó"); ConfigState conserva
# datos persistentes mientras la app está abierta (algo "es").
# ---------------------------------------------------------------------------
extends Node

var moto_seleccionada: String = ""
var color_seleccionado: String = "Sin seleccionar"
var accesorios_seleccionados: Array[String] = []
var precio_total: int = 0

func agregar_accesorio(nombre: String, precio: int) -> void:
	if not accesorios_seleccionados.has(nombre):
		accesorios_seleccionados.append(nombre)
		precio_total += precio

func quitar_accesorio(nombre: String, precio: int) -> void:
	if accesorios_seleccionados.has(nombre):
		accesorios_seleccionados.erase(nombre)
		precio_total -= precio

func establecer_color(nombre_color: String) -> void:
	color_seleccionado = nombre_color

func reiniciar() -> void:
	moto_seleccionada = ""
	color_seleccionado = "Sin seleccionar"
	accesorios_seleccionados.clear()
	precio_total = 0
