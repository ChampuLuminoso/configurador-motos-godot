# ADR-008: El minijuego cambia a cinta transportadora + canastas (clic en vez de movimiento)

* **Estado:** Aprobado
* **Fecha:** 30/10/2026
* **Autor:** Jorge Eliecer Montes Rodríguez

## Contexto

ADR-007 cambió el minijuego a clasificación por zonas, pero mover al
mecánico con el teclado hasta la zona correcta mientras las piezas
caían resultó confuso. El estudiante propuso una modalidad distinta:
una cinta transportadora que trae los repuestos, y clasificarlos con
el mouse (clic para tomar, clic en una canasta para soltar), aportando
los íconos del "mecánico" (usado como cursor personalizado), una caja
abierta (usada como canasta) y la cinta transportadora.

## Decisión

- Se **eliminó** por completo la mecánica anterior basada en física:
  `player.gd` (`CharacterBody2D` con movimiento por teclado),
  `spawner.gd`/`spawner.tscn` (generador con impulsos físicos) y
  `falling_part.gd`/`falling_part.tscn` (`RigidBody2D` con gravedad).
- **`belt_part.gd`/`.tscn`** (nuevo, reemplaza a `falling_part`): un
  `Area2D` sin física que se desliza en línea recta por la cinta
  (`position.x += speed * delta`) y detecta clics con su propia señal
  `input_event`. Si nadie le hace clic antes de llegar al final de la
  cinta, se pierde (cuenta como error).
- **`basket.gd`/`.tscn`** (nuevo): una canasta clickeable
  (`zone_id: String`, configurable desde el Inspector) con el ícono de
  caja aportado por el estudiante y una etiqueta de categoría debajo.
  Hay 3 en la escena: Motor, Transmisión y Descarte.
- **Cursor personalizado:** se usa `Input.set_custom_mouse_cursor()`
  con el ícono del mecánico y un **hotspot** (el píxel exacto que
  cuenta como el clic) marcado con un puntito justo arriba de la
  cabeza del personaje — así el jugador ve claramente dónde va a
  registrar el clic, en vez de adivinar con un ícono grande.
- **Flujo de juego:** clic sobre una pieza de la cinta → queda "en la
  mano" (dejó de moverse por la cinta, ahora sigue al cursor) → clic
  sobre una canasta → se evalúa si es la correcta (repuestos buenos
  van a su subsistema, dañados/chatarra siempre a Descarte, igual regla
  de ADR-007) y se libera la pieza.
- `coupon_game.gd` absorbió la generación de piezas directamente (ya no
  hace falta un nodo `Spawner` genérico reutilizable — solo hay un
  punto de entrada: el inicio de la cinta).
- El fondo del taller (ADR-007) se mantuvo; se agregó la imagen de la
  cinta transportadora como una franja `TextureRect` en modo
  `STRETCH_TILE` sobre el fondo.

## Consecuencias

- La FSM (`PLAYING -> WON/LOST` vía `change_state()`) no cambió de
  forma, solo las señales que la alimentan: antes eran colisiones
  físicas (`body_entered`), ahora son clics (`input_event` de
  `Area2D`, que requiere `get_viewport().physics_object_picking = true`,
  activado en `_ready()`).
- Se perdió el "mecánico visible moviéndose por el taller" de ADR-007
  — ahora el personaje vive solo como ícono del cursor. Si más
  adelante se quiere una presencia visible del personaje en pantalla
  (no solo como cursor), habría que agregarlo como un nodo aparte.
- Igual que en los rediseños anteriores, no se pudo probar en vivo en
  este entorno (no hay editor de Godot instalado): queda pendiente
  confirmar en Godot que el clic registra bien en la cabeza del
  personaje (el hotspot), que la cinta se ve continua al repetirse, y
  que el ritmo de piezas se sienta jugable con clics en vez de
  movimiento.
