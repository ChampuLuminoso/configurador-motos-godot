# Registro de depuración — Laboratorio 10, Parte 1

Esta parte requiere correr el editor de Godot en vivo y detenerte en un
breakpoint — eso solo lo puedes hacer tú desde tu máquina. Aquí te dejo
elegida la función y el paso a paso; completa las respuestas mientras lo
haces.

## Función sugerida para inspeccionar

`GlobalManager.get_best_coupon(subtotal: int)` en
`res://src/core/global_manager.gd`.

Es una buena candidata porque tiene una condición (`if subtotal >=
coupon["minimum_purchase"]`) y una comparación dentro de un bucle
(`elif coupon["value"] > best_coupon["value"]`), así que hay algo real
que observar cambiar en cada vuelta — no es una línea suelta.

## Pasos

1. Abre `global_manager.gd` en el editor.
2. Haz clic en el margen izquierdo, junto al número de línea del `for
   coupon: Dictionary in coupons:` (o la línea del `if` dentro del
   bucle), para colocar el breakpoint.
3. Ejecuta el proyecto, juega el minijuego "Taller de Repuestos" hasta
   ganar un cupón, y luego ve a la pantalla de factura
   (`purchase_invoice`) — ahí es donde se llama `get_best_coupon()`.
4. Cuando el programa se detenga, abre el panel **Variables** del
   depurador y observa `subtotal`, `coupon` y `best_coupon`.
5. Usa **Paso a paso (F7)** o **Pasar por encima (F8)** para avanzar
   línea por línea y mira cómo `best_coupon` se actualiza (o no) en
   cada vuelta del bucle.

## Responde brevemente

- **¿Qué aprendió?** Explique qué pudo observar usando el breakpoint.

  _(tu respuesta aquí)_

- **¿Le resultó útil?** Indique si el depurador le ayudó a comprender
  mejor la ejecución del código y por qué.

  _(tu respuesta aquí)_

- **Ejemplo:** describa una variable o instrucción que pudo inspeccionar
  y qué descubrió al hacerlo.

  _(tu respuesta aquí — por ejemplo, qué valor tenía `best_coupon` antes
  y después de que el bucle encontrara un cupón de mayor valor)_
