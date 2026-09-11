# res://src/core/event_bus.gd
# ---------------------------------------------------------------------------
# EVENT BUS (Autoload / Singleton) — Mismo patrón del Laboratorio 2.
# Canal global para desacoplar la navegación y la comunicación entre
# escenas. Ninguna escena conoce a otra directamente.
# ---------------------------------------------------------------------------
extends Node

## Navegación entre pantallas (igual que en el Lab 2).
signal navigation_requested(target_scene_path: String)

## Cambios de configuración: color elegido, accesorio agregado/quitado, etc.
signal parameter_changed(param_name: String, value: Variant)
