# ADR-003: Máquina de Estado Finito para el minijuego "Taller de Repuestos"

* **Estado:** Aprobado
* **Fecha:** 02/10/2026
* **Autor:** Jorge Eliecer Montes Rodríguez

## Contexto

El controlador del minijuego determinaba si había terminado mediante una
variable booleana (`game_finished`) y dos funciones casi idénticas
(`win_game()`, `lose_game()`). No dejaba explícito qué estados existen
ni qué transiciones son válidas.

## Decisión

Se modela el minijuego con `enum GameState { PLAYING, WON, LOST }`.
Toda transición pasa por `change_state(new_state)`, que consulta
`_is_transition_allowed(from, to)` antes de aplicarse. Solo
`PLAYING -> WON` y `PLAYING -> LOST` son válidas; `WON` y `LOST` son
terminales.

Se separa el comportamiento propio de entrar a un estado
(`_enter_won()`/`_enter_lost()`: detener el minijuego, emitir el cupón,
fijar el mensaje) de la animación asociada a la transición
(`_reproducir_animacion_resultado()`), que es la misma sin importar el
resultado — anima la aparición del panel, no el resultado en sí.

## Consecuencias

### Positivas
- Reglas explícitas y centralizadas: imposible "ganar después de
  perder" por diseño, no por disciplina del programador.
- La animación Tween (escala + opacidad del panel) comunica visualmente
  el cambio de estado, en vez de aparecer de golpe.
- El botón "Volver" se deshabilita mientras la animación corre, evitando
  interacción con un panel aún en formación.

### Negativas / Costos
- Más código que la versión con un solo booleano, para solo dos estados
  terminales.
