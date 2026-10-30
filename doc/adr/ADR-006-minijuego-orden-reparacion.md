# ADR-006: Minijuego "Taller de Repuestos" como orden de reparación con checklist

* **Estado:** Aprobado
* **Fecha:** 30/10/2026
* **Autor:** Jorge Eliecer Montes Rodríguez

## Contexto

El minijuego "Taller de Repuestos" (Laboratorio 6, FSM) existía desde
antes del Laboratorio 9/10, pero solo mecánicamente: el jugador atrapaba
repuestos genéricos (un cuadrado de color cayendo) hasta sumar un
número fijo, sin relación real con el dominio de motos. No tenía
sentido narrativo por qué un mecánico necesitaría atrapar 8 cosas
iguales para ganar un cupón.

## Decisión

Se rediseñó el minijuego como una **orden de reparación con
checklist**, manteniendo intacta la FSM original (`PLAYING -> WON /
LOST`, `change_state()` como único punto de cambio de estado):

- **`PartData`** (`Resource`): un repuesto — `id`, `display_name`,
  `texture`, `category` (`GOOD` / `DAMAGED` / `JUNK`). Mismo patrón que
  `RimData` del Laboratorio 9.
- **`PartDatabase`** (`Resource`): catálogo completo (`part_database.tres`),
  12 repuestos: 4 buenos (filtro de aceite, piñón, bujía, cadena), 5
  versiones dañadas de esos mismos tipos (para que el jugador tenga que
  fijarse en la pieza real y no solo en un color de advertencia) y 3
  piezas de chatarra de taller (tornillo, arandela, tuerca oxidada) que
  nunca son válidas.
- Al iniciar la partida, `coupon_game.gd` genera una orden aleatoria:
  2-3 tipos de repuesto **bueno**, con cantidad 1-2 de cada uno.
- `spawner.gd` ya no instancia siempre la misma escena vacía: elige un
  `PartData` al azar del catálogo completo en cada spawn (con los
  repuestos buenos apareciendo 3 veces más seguido que los dañados o la
  chatarra, para que la orden sea alcanzable).
- Recolectar un repuesto que la orden todavía necesita suma progreso;
  recolectar cualquier otra cosa (dañado, chatarra, o un repuesto bueno
  que ya no hace falta) suma un error. `WON` cuando se completa el
  checklist, `LOST` al llegar a `max_mistakes` errores.

## Consecuencias

- El cupón obtenido (`EventBus.coupon_obtained`) y su integración con
  `GlobalManager`/factura no cambiaron — solo cambió cómo se gana.
- Los íconos de "dañado" fueron aportados por el estudiante; uno de
  ellos (`bujia_danada_2`, ícono azul con triángulo de advertencia) no
  se pudo identificar con certeza como bujía — queda documentado por si
  se requiere renombrarlo o reemplazarlo.
- Quedó pendiente de ejecución real en Godot (este entorno no tiene el
  editor instalado): confirmar que las texturas se vean con el tamaño y
  proporción esperados dentro de `falling_part.tscn`.
