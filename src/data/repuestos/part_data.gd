# res://src/data/repuestos/part_data.gd
# Un repuesto del minijuego "Taller de Repuestos", modelado como Resource
# (mismo patrón que RimData en el Laboratorio 9) para poder editarlo desde
# el Inspector sin tocar código.
#
# category decide si el repuesto es válido:
#   GOOD    -> un repuesto real en buen estado. Hay que clasificarlo en
#              su zona de subsistema (Motor o Transmisión).
#   DAMAGED -> versión rota de un repuesto real. Siempre va a Descarte.
#   JUNK    -> tornillería/chatarra del taller, no es un repuesto de
#              moto. Siempre va a Descarte.
#
# subsystem solo es relevante para repuestos GOOD (decide si su zona
# correcta es Motor o Transmisión); en repuestos DAMAGED/JUNK se deja
# como referencia informativa, pero el minijuego los manda a Descarte
# sin mirar este campo.
class_name PartData
extends Resource

enum Category { GOOD, DAMAGED, JUNK }
enum Subsystem { MOTOR, TRANSMISION, NINGUNO }

@export var id: String
@export var display_name: String
@export var texture: Texture2D
@export var category: Category = Category.GOOD
@export var subsystem: Subsystem = Subsystem.NINGUNO
