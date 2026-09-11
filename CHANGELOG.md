# Changelog

## [1.0.0] - 2026

### Added
- Proyecto inicial: menú, configurador y créditos
- Navegación básica entre pantallas
- `GlobalManager` (Autoload) para el estado centralizado de la configuración
- Componente reutilizable `ButtonNav` con pila de historial de navegación
- Señales `color_selected`, `color_changed`, `accessory_toggled` y `total_changed` en el EventBus
- ADR-001 documentando la decisión de arquitectura

### Changed
- Navegación migrada de callbacks propios por escena a `ButtonNav` declarativo
- `EventBus.navigation_requested` ampliada con el parámetro `discard_previous`

### Removed
- Autoload `ConfigState` (reemplazado por `GlobalManager`)

### Fixed
- (Pendiente)
