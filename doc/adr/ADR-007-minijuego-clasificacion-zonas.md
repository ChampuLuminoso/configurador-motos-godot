# ADR-007: El minijuego cambia de "orden de reparación" a clasificación por zonas

* **Estado:** Aprobado
* **Fecha:** 30/10/2026
* **Autor:** Jorge Eliecer Montes Rodríguez

## Contexto

ADR-006 le había dado sentido narrativo al minijuego con una orden de
reparación (checklist de cantidades). El estudiante pidió ir un paso
más allá: cambiar la **modalidad** completa a clasificar repuestos, y
aportó una imagen de un taller/garaje para usar como escenario real en
vez del fondo vacío anterior.

## Decisión

- El piso del taller ahora tiene **3 zonas marcadas**: `MOTOR`,
  `TRANSMISIÓN` y `DESCARTE`, dibujadas como franjas de color
  semitransparente sobre la imagen de fondo (`taller_fondo.png`).
- Los repuestos se siguen generando y cayendo igual que en ADR-006
  (mismo `PartDatabase`, mismo `spawner.gd`). Lo que cambia es la regla
  de acierto: ya no importa la cantidad, importa **en qué zona está
  parado el jugador cuando atrapa la pieza**:
  - Repuesto bueno (`GOOD`) → su zona correcta es la de su nuevo campo
    `subsystem` (`MOTOR` o `TRANSMISION`).
  - Repuesto dañado (`DAMAGED`) o chatarra (`JUNK`) → su zona correcta
    es siempre `DESCARTE`, sin importar a qué se parezca.
- Se agregó `PartData.subsystem` (enum `MOTOR / TRANSMISION / NINGUNO`)
  para poder calcular la zona correcta de cada repuesto bueno.
- La FSM (`PLAYING -> WON/LOST` vía `change_state()`) no cambió de
  forma; solo cambió qué cuenta como acierto/error: antes
  "¿completaste el checklist?", ahora "¿lo clasificaste en la zona
  correcta?". `WON` a los `target_aciertos` (10 por defecto), `LOST` a
  los `max_errores` (5 por defecto).
- Se ocultaron los elementos visuales planos anteriores (piso gris,
  paredes del embudo naranjas) dejando solo su colisión, para que se
  vea la imagen de fondo real sin elementos duplicados encima.

## Consecuencias

- Se eliminó por completo la idea de "orden de reparación con
  cantidades" de ADR-006 — el checklist en pantalla fue reemplazado por
  un marcador simple de aciertos/errores y una instrucción breve de qué
  va en cada zona.
- El cupón obtenido (`EventBus.coupon_obtained`) sigue funcionando
  igual; solo cambia cómo se gana la partida.
- Queda pendiente de ejecución real en Godot (este entorno no tiene el
  editor instalado): confirmar que las 3 zonas se vean bien ubicadas
  sobre la imagen de fondo real, y que el jugador no se sienta "tapado"
  por las franjas de color al pararse sobre ellas.
