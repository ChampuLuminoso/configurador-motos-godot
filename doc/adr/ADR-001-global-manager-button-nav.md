# ADR-001: Centralización del estado (GlobalManager) y navegación reutilizable (ButtonNav)

## Estado
Aceptado

## Contexto
La primera versión de este configurador resolvía la navegación con
llamadas directas dentro de cada escena, y guardaba la selección de
color y accesorios en un Autoload (`ConfigState`) al que cada panel
llamaba directamente (`ConfigState.agregar_accesorio(...)`). Esto
funcionaba, pero acoplaba cada pantalla a la forma interna en que
`ConfigState` guardaba sus datos, y no existía ningún historial de
navegación: solo se sabía la pantalla actual, no de dónde venía el
usuario.

## Decisión
Se reemplaza `ConfigState` por `GlobalManager`
(`src/core/global_manager.gd`), que ya no es llamado directamente por
los paneles. En su lugar:

- Los paneles **emiten intenciones** al `EventBus` (`color_selected`,
  `accessory_toggled`).
- `GlobalManager` **escucha** esas intenciones, actualiza su propio
  estado (`Dictionary` de precios, `Array` de accesorios activos) y
  **devuelve el resultado** emitiendo `color_changed` y `total_changed`.
- Se crea el componente reutilizable `ButtonNav`
  (`src/components/navigation/button_nav.tscn`), configurable desde el
  Inspector con `target_scene` y `discard_previous`.
- `MainApp` mantiene `navigation_history: Array[String]`, apilando con
  `.append()` al avanzar y desapilando con `.pop_back()` al volver.

## Consecuencias

### Positivas
- Ningún panel calcula precios ni conoce a `GlobalManager` directamente.
- `config_panel` y `credits_panel` ya no necesitan repetir su propio
  callback de navegación: usan la misma instancia de `ButtonNav`.
- El historial de navegación queda centralizado en un solo lugar
  (`MainApp`), en vez de que cada escena intente recordarlo por su cuenta.

### Negativas / Trade-offs
- Un Autoload más (`GlobalManager`) sumado a `EventBus`, que debe usarse
  con disciplina para no convertirse en una bolsa de estado desordenada.
- Seguir el rastro de un cambio ahora implica revisar tres archivos (el
  emisor, `GlobalManager`, y el receptor) en vez de una sola función.
