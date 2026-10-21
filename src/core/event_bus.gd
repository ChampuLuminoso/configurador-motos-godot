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

# Una actividad externa (el minijuego de repuestos) produjo un cupón.
# El minijuego no conoce la pantalla de compra: solo publica el
# resultado aquí. Agregado en el Laboratorio 5.
signal coupon_obtained(coupon: Dictionary)

# Laboratorio 9 — personalización de rines mediante catálogo (Resource).
# Avisas que elegiste un rin para una rueda puntual. "wheel" es "front"
# o "rear": cada rueda se elige de forma independiente, igual que cada
# mitad de la pizza en la guía.
signal rim_selected(rim_id: String, wheel: String)

# GlobalManager te devuelve el total ya recalculado incluyendo los
# rines elegidos.
signal rim_total_changed(new_total: int)
