# DEVLOG

## Actividad — Gestión de Estado Global y Componentes Reutilizables

| Campo | Detalle |
|---|---|
| Fecha | 11/09/2026 |
| Funcionalidades implementadas | Se creó `GlobalManager` (Autoload) para centralizar el color y los accesorios elegidos, junto con el cálculo del precio total. Se actualizó `EventBus` con las señales `color_selected`, `color_changed`, `accessory_toggled` y `total_changed`, y se amplió `navigation_requested` con el parámetro `discard_previous`. Se creó el componente reutilizable `ButtonNav`, y `MainApp` ahora administra `navigation_history` con `.append()`/`.pop_back()`, imprimiendo su estado en consola. Las tres escenas (menú, configurador, créditos) se migraron para usar `ButtonNav` en vez de callbacks de navegación propios. |
| Dificultades encontradas | Decidir qué hacer con el color al centralizarlo: el color no afecta el precio, pero se optó por manejarlo igual a través de `GlobalManager` (con su propia señal `color_changed`) para mantener un solo patrón consistente en todo el proyecto, en vez de tener una excepción especial solo para el color. |
| Decisiones de diseño | Se documentó la decisión completa en `doc/adr/ADR-001-global-manager-button-nav.md`. Se decidió mantener un script mínimo en `credits_panel.gd` (solo para la animación de entrada) en vez de dejarlo completamente sin script, priorizando el detalle visual sobre la pureza del patrón. |
| Próximos pasos | Agregar fotos reales de la moto en vez del `ColorRect` de vista previa. Evaluar persistencia en disco de la configuración elegida. |
