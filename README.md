# Configurador de Motos — Resumen de lo implementado.

## 📂 Estructura final del proyecto

```
moto-configurador/
├── .gitignore
├── README.md
├── project.godot
└── src/
	├── core/
	│   ├── event_bus.gd          <- Autoload "EventBus"
	│   ├── config_state.gd       <- Autoload "ConfigState"
	│   ├── main_app.gd
	│   └── main_app.tscn         <- Escena principal
	└── scenes/
		├── menu/
		│   ├── menu_panel.gd
		│   └── menu_panel.tscn
		├── configurator/
		│   ├── configurator_panel.gd
		│   └── configurator_panel.tscn
		└── credits/
			├── credits_panel.gd
			└── credits_panel.tscn
```

## 🧱 Del Laboratorio 1 
- Nodo raíz `Control` en las 3 escenas de interfaz.
- Layout con `VBoxContainer`, `HBoxContainer` y `GridContainer` — sin
  posiciones absolutas en píxeles.
- Tipado estático estricto en todas las funciones y variables.
- `@onready` para capturar nodos, `$` solo en la declaración inicial.
- Un único callback por grupo de botones homogéneos, parametrizado con
  `.bind()`:
  - 3 botones de color → `_on_color_selected(nombre_color)`
  - 3 botones de accesorios → `_on_accesorio_toggled(activado, nombre, precio)`
  - Botones de navegación del menú → `_on_navigate_pressed(target_scene_path)`

## 🧱 Del Laboratorio 2
- `EventBus` (Autoload) con señales tipadas:
  - `navigation_requested(target_scene_path: String)`
  - `parameter_changed(param_name: String, value: Variant)`
- `MainApp` como orquestador único: se suscribe al bus, libera la escena
  anterior con `queue_free()`, limpia la referencia (`current_scene = null`)
  e instancia la siguiente.
- Ninguna escena conoce a otra directamente — solo se comunican vía
  `EventBus`.
- Estructura modular con co-localización (escena + script juntos por
  carpeta).

## 🆕 Piezas nuevas agregadas

### 1. Panel de Configurador (`configurator_panel`)
- Sidebar con 3 colores (botones normales) y 3 accesorios (botones con
  `toggle_mode = true`, funcionan como checkboxes).
- `VistaMoto` (`ColorRect`): espacio reservado para las fotos de motos —
  hoy cambia de color como feedback visual provisional, con instrucciones
  en el código de cómo pasarlo a `TextureRect` con imágenes reales.
- `LblTotal`: suma en tiempo real el precio de los accesorios activos.

### 2. `ConfigState` 
Guarda en memoria mientras la app está abierta:
```gdscript
var moto_seleccionada: String = ""
var color_seleccionado: String = "Sin seleccionar"
var accesorios_seleccionados: Array[String] = []
var precio_total: int = 0
```
Con funciones `agregar_accesorio()`, `quitar_accesorio()`,
`establecer_color()`, `reiniciar()`.

Resuelve la persistencia de estado entre escenas: si sales del
configurador y vuelves a entrar, tu selección sigue ahí (se restaura en
`_restaurar_estado_guardado()`).

### 3. Panel de Créditos 
- Jorge Eliecer Montes Rodríguez
- Ingeniería de Software
- Producción de Videojuegos - UAN 2026-2
- Botón "Volver al Menú" vía `EventBus`

Conectado desde el menú con el mismo callback unificado (`.bind()`) que
usa el botón de configurador.

### 4. Transiciones con `Tween` (fade-in)
Agregado a los 3 paneles (`menu_panel`, `configurator_panel`,
`credits_panel`):
```gdscript
func _reproducir_fade_in() -> void:
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
```
Cada panel arranca invisible y aparece con un desvanecido suave de 0.4
segundos al entrar, en vez de aparecer de golpe.

## ⚙️ Autoloads registrados en `project.godot`
```ini
[autoload]
EventBus="*res://src/core/event_bus.gd"
ConfigState="*res://src/core/config_state.gd"
```

## 🚀 Pendientes / ideas para seguir
- ADR-0002 documentando por qué se separó `ConfigState` de `EventBus`.
- Reorganizar accesorios en `GridContainer` de 2 columnas (hoy es lista
  de 1 columna).
- DEVLOG propio de este proyecto.
- Fade-out antes de cambiar de escena (usando `await tween.finished`).
- Fotos reales de motos reemplazando el `ColorRect` por `TextureRect`.
- Nodos con `%NombreUnico` en vez de rutas `$` largas.
