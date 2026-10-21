# res://src/data/rim_database.gd
# Laboratorio 9 — Catálogo de rines disponibles.
# RimData representa un rin individual; RimDatabase representa la
# colección completa que la interfaz puede recorrer para generar sus
# propios botones, sin que el código de la interfaz sepa cuántos
# estilos existen.
class_name RimDatabase
extends Resource

@export var rims: Array[RimData] = []
