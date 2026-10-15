# Hallazgos UX — Laboratorio 8

> **Nota importante:** las 3 fricciones de abajo son un análisis hecho
> revisando el código y el flujo del minijuego "Taller de Repuestos"
> (equivalente a "Pizza Rush" en la guía), **no sustituyen la prueba de
> usuario real** que pide la Parte 1 de la guía. Haz tu propia prueba
> siguiendo `doc/ux/test_usuario_lab8.md` y, si tu usuario encuentra las
> mismas fricciones (o distintas), reemplaza o complementa esta tabla con
> lo que observaste de verdad — eso es lo que se sustenta en el video.

## Hallazgo 1 — No hay instrucciones de movimiento en pantalla

**Situación:** al entrar al minijuego "Taller de Repuestos", la escena no
muestra ningún texto con las teclas de movimiento. El jugador solo ve el
`Label` de objetivo ("Repuestos: 0 / 8") en una esquina. La única forma de
descubrir que se usa A/D o las flechas es probando al azar.

**Mejora propuesta:** agregar un `Label` breve y visible al iniciar el
minijuego, por ejemplo "Muévete con ← → o A/D", ubicado cerca del jugador
o en la parte superior, que puede desaparecer solo después de los
primeros segundos o del primer movimiento detectado.

**Resultado esperado:** el jugador entiende cómo moverse en los primeros
1-2 segundos sin necesidad de probar teclas al azar, reduciendo el tiempo
muerto al inicio del minijuego.

## Hallazgo 2 — La derrota llega sin ninguna advertencia previa

**Situación:** `coupon_game.gd` cambia a `GameState.LOST` en el instante
exacto en que `current_spawned_items` supera `max_spawned_items` (línea
`_on_item_spawned`). No hay ningún aviso cuando el jugador se está
acercando a ese límite — el contador de repuestos caídos no es visible en
ningún `Label`, a diferencia del contador de repuestos recolectados.

**Mejora propuesta:** mostrar un segundo indicador visible (por ejemplo
"Repuestos caídos: 4 / 20") junto al de objetivo, y opcionalmente cambiar
su color (blanco → naranja → rojo) a medida que se acerca al límite, para
que la derrota se sienta como consecuencia de algo que el jugador podía
ver venir, no como un corte abrupto.

**Resultado esperado:** el jugador percibe el riesgo de perder antes de
que ocurra y puede ajustar su estrategia (priorizar recolectar en vez de
dejar caer), en lugar de que el fin del juego se sienta arbitrario.

## Hallazgo 3 — El botón "Cerrar" del popup de compra no da retroalimentación inmediata

**Situación:** en `purchase_invoice.gd`, al presionar "Confirmar compra"
aparece el nuevo `PurchaseSuccessPopup`, pero no hay ninguna animación de
entrada (aparece de golpe) ni cambio de cursor/estado al pasar el mouse
sobre "Cerrar", a diferencia de los demás botones del tema industrial que
sí cambian de color en hover. En una prueba rápida, esto puede hacer que
un usuario dude si su clic realmente funcionó.

**Mejora propuesta:** aplicar el mismo patrón de `Tween` de escala +
opacidad que ya se usa en `ResultPanel` del minijuego (`_reproducir_animacion_resultado`)
al mostrar `PurchaseSuccessPopup`, reutilizando el mismo patrón visual en
vez de uno nuevo.

**Resultado esperado:** la confirmación de compra se siente consistente
con el resto de la interfaz y el usuario percibe de inmediato que la
acción fue exitosa, sin necesidad de fijarse en el texto para confirmarlo.

---

## Íconos identificados para elementos clave de la interfaz

La guía pide **identificar** qué ícono usaría para cada elemento clave,
no necesariamente incorporarlo todavía. Esta tabla documenta la decisión;
implementarlos como imágenes reales queda en el Backlog.

| Elemento | Ícono sugerido | Dónde se usaría |
|---|---|---|
| Volver / atrás | Flecha apuntando a la izquierda (←) | `ButtonNav` en todas las pantallas (ya genérico, podría mostrarse junto al texto "Volver") |
| Cerrar | X simple | `BtnCerrarPopup` en `PurchaseSuccessPopup` |
| Confirmar compra | Check / palomita (✓) | `BtnConfirm` en `purchase_invoice` |
| Eliminar / quitar accesorio | Papelera o X pequeña | Futuro botón para quitar un accesorio ya agregado desde el configurador |
| Iniciar minijuego | Triángulo de play (▶) | Botón "Conseguir Cupones" en el menú, para reforzar que lleva a una actividad jugable y no a otra pantalla estática |

Fuente sugerida para los íconos reales: un set de línea simple y
consistente como *Material Symbols* o *Kenney Game Icons* (ambos de uso
libre), para que los 5 íconos compartan el mismo grosor de línea y estilo
que el tema industrial ya aplicado.
