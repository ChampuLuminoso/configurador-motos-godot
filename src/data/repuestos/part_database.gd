# res://src/data/repuestos/part_database.gd
# Catálogo completo de repuestos del minijuego (buenos, dañados y
# chatarra), mismo patrón que RimDatabase en el Laboratorio 9.
class_name PartDatabase
extends Resource

@export var parts: Array[PartData] = []

func of_category(category: PartData.Category) -> Array[PartData]:
	var result: Array[PartData] = []
	for part in parts:
		if part.category == category:
			result.append(part)
	return result
