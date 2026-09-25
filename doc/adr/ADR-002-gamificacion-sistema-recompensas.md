# ADR-002: Integración de Gamificación y Sistema de Recompensas Desacoplado

* **Estado:** Aprobado
* **Fecha:** 25/09/2026
* **Autor:** Jorge Eliecer Montes Rodríguez

## Contexto

El proyecto ya usa un `EventBus` (ADR-001) para desacoplar la
comunicación entre escenas y un `GlobalManager` para el estado
compartido de la configuración de la moto. Se quiere agregar una
mecánica de gamificación — un minijuego de recolección de repuestos —
capaz de generar cupones de descuento para la compra de accesorios,
sin acoplar el minijuego a la pantalla de configuración/compra.

## Decisión

El minijuego (`src/scenes/gamification/coupon_game.tscn`) vive en su
propia carpeta, independiente de `configurator/` y `purchase_invoice/`.
Al ganar, emite `EventBus.coupon_obtained(coupon: Dictionary)`.
`GlobalManager` escucha esa señal, guarda el cupón en `coupons`, y la
pantalla de factura consulta `get_best_coupon(subtotal)` para aplicar
automáticamente el de mayor valor válido.

## Consecuencias

### Positivas
- El minijuego no conoce la pantalla de compra ni viceversa.
- Los cupones se administran desde un único punto (`GlobalManager`).
- Se puede reemplazar el minijuego por otra fuente de recompensas sin
  tocar la lógica de compra.

### Negativas / Costos
- Un flujo de recompensa más largo de seguir al depurar (minijuego →
  EventBus → GlobalManager → factura).
- `GlobalManager` gana una responsabilidad adicional (reglas de cupones).
