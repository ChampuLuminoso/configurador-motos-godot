# res://src/core/event_bus.gd
# Este es tu canal global de señales: aquí no pones lógica, solo declaras
# qué eventos pueden pasar en tu app. Ninguna escena habla directo con
# otra ni con GlobalManager, todas pasan por aquí.
extends Node

# Pides navegar a otra escena. Marca discard_previous en true si es un
# botón de "volver" (así MainApp sabe que debe quitar del historial en
# vez de agregar).
signal navigation_requested(target_scene: String, discard_previous: bool)

# Avisas que elegiste un color.
signal color_selected(color_name: String)

# GlobalManager te devuelve el color ya confirmado, para que actualices
# lo que necesites mostrar.
signal color_changed(color_name: String)

# Avisas que activaste o desactivaste un accesorio.
signal accessory_toggled(accessory_id: String, active: bool)

# GlobalManager te devuelve el total ya recalculado.
signal total_changed(new_total: int)
