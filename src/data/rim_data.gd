# res://src/data/rim_data.gd
# Laboratorio 9 — Representación de datos mediante Resource.
# Describe un solo estilo de rin disponible en el catálogo: qué textura
# usa, cómo se llama y cuánto cuesta. No sabe nada de interfaz ni de
# en qué rueda (delantera/trasera) se va a usar.
class_name RimData
extends Resource

@export var id: String
@export var display_name: String
@export var texture: Texture2D
@export var price: int
