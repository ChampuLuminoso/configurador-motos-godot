# DEVLOG

## Actividad — Gestión de Estado Global y Componentes Reutilizables

| Campo | Detalle |
|---|---|
| Fecha | 11/09/2026 |
| Funcionalidades implementadas | Se creó `GlobalManager` (Autoload) para centralizar el color y los accesorios elegidos, junto con el cálculo del precio total. Se actualizó `EventBus` con las señales `color_selected`, `color_changed`, `accessory_toggled` y `total_changed`, y se amplió `navigation_requested` con el parámetro `discard_previous`. Se creó el componente reutilizable `ButtonNav`, y `MainApp` ahora administra `navigation_history` con `.append()`/`.pop_back()`, imprimiendo su estado en consola. Las tres escenas (menú, configurador, créditos) se migraron para usar `ButtonNav` en vez de callbacks de navegación propios. |
| Dificultades encontradas | Decidir qué hacer con el color al centralizarlo: el color no afecta el precio, pero se optó por manejarlo igual a través de `GlobalManager` (con su propia señal `color_changed`) para mantener un solo patrón consistente en todo el proyecto, en vez de tener una excepción especial solo para el color. |
| Decisiones de diseño | Se documentó la decisión completa en `doc/adr/ADR-001-global-manager-button-nav.md`. Se decidió mantener un script mínimo en `credits_panel.gd` (solo para la animación de entrada) en vez de dejarlo completamente sin script, priorizando el detalle visual sobre la pureza del patrón. |
| Próximos pasos | Agregar fotos reales de la moto en vez del `ColorRect` de vista previa. Evaluar persistencia en disco de la configuración elegida. |

## Interacción y Mecánicas Básicas (patrón Lab 5)

| Campo | Detalle |
|---|---|
| Fecha | 18/09/2026 |
| Funcionalidades implementadas | Se agregó entrada por teclado en `configurator_panel`: teclas 1/2/3 seleccionan color, teclas 4/5/6 alternan accesorios, reutilizando los mismos callbacks que ya usaban los botones. Se agregó una zona de interacción reactiva: al pasar el mouse sobre cualquier botón de color o accesorio, un `Label` (`LblZonaActiva`) muestra cuál opción está bajo el cursor. |
| Dificultades encontradas | Alternar un accesorio por teclado sin duplicar lógica: se resolvió con una función auxiliar `_alternar_accesorio_por_teclado()` que cambia el estado visual del botón y llama al mismo callback que ya manejaba el evento `toggled`. |
| Decisiones de diseño | Igual que en el proyecto del curso, se usaron las señales nativas `mouse_entered`/`mouse_exited` en vez de colisiones, porque el proyecto es una interfaz 2D de `Control`. |
| Próximos pasos | Agregar fotos reales de motos. Evaluar una pequeña máquina de estados para el flujo de selección. |

## Gamificación y Sistema de Recompensas (patrón Lab 5 — guía real)

| Campo | Detalle |
|---|---|
| Fecha | 25/09/2026 |
| Funcionalidades implementadas | Minijoego "Taller de Repuestos" (`gamification/coupon_game.tscn`): jugador controlado por teclado, repuestos que caen y rebotan, suelo y embudo físicos, generación progresiva con spawners. Nueva señal `coupon_obtained` en el EventBus. `GlobalManager` administra cupones (`get_best_coupon`, `remove_coupon`). Nueva pantalla de factura (`purchase_invoice/`) que aplica el descuento automáticamente. Acceso desde el menú vía "Conseguir Cupones". |
| Dificultades encontradas | Adaptar el flujo genérico de la guía (pensado para "bases e ingredientes") al dominio de motos: se tradujo a "color y accesorios", y los objetos recolectables pasaron a llamarse "repuestos" en vez de "ingredientes". |
| Decisiones de diseño | Igual que en el proyecto del curso, se usó `ColorRect` como marcador visual en vez de sprites reales por ahora (ver `LEEME.md`). Documentado en `ADR-002`. |
| Próximos pasos | Agregar sprites reales. Probar el flujo completo: menú → cupón → minijuego → configurador → factura → confirmación. |

## [2026-10-02] - Laboratorio 6: Máquina de Estado Finito y Animación Tween

**Comportamiento y estados implementados:** se modeló `coupon_game.gd` (minijuego "Taller de Repuestos") como una FSM con tres estados: `PLAYING`, `WON`, `LOST`. Las transiciones válidas pasan por `change_state()`, que valida contra `_is_transition_allowed()` antes de aplicar cualquier cambio.

**Dificultades encontradas:** separar el comportamiento propio de cada estado terminal (emitir cupón, detener spawners) de la animación de la transición, que debía ser la misma sin importar el resultado.

**Animación Tween incorporada:** el `ResultPanel` aparece con una animación de escala y opacidad (`TRANS_BACK`/`EASE_OUT`) al entrar a `WON` o `LOST`. El botón "Volver" se deshabilita mientras dura la animación.

**Próximos pasos:** evaluar FSM para el flujo de configuración (color → accesorios → factura).

## [2026-10-09] - Persistencia de Cupones (patrón Lab 7)

**Actividades realizadas:**
- Se implementó persistencia de cupones en `GlobalManager` usando `FileAccess` y `JSON` (`SAVE_PATH = "user://save_data.json"`). Se guarda al obtener y al consumir un cupón; se carga una sola vez al iniciar.
- Se recorrió el flujo completo: menú → configurador → cupones → minijuego → factura, confirmando que todo sigue integrado.

**Desafíos encontrados:**
[COMPLETAR si tuviste alguno]

**Estado final:**
[COMPLETAR: confirma que probaste cerrar/reabrir y que el cupón persiste]
