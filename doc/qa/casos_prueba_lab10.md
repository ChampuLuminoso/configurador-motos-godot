# Casos de prueba — Laboratorio 10

> Nota sobre cómo se obtuvieron los resultados: los casos **UNI-01** y
> **UNI-02** están automatizados con GdUnit4 (ver `tests/`) y sus
> resultados abajo salen de trazar el código a mano, línea por línea,
> contra la implementación real de `global_manager.gd` — no de
> ejecutar Godot, porque este entorno no tiene el editor instalado.
> Antes de entregar, **ábrelos en tu Godot y corre la suite** (Alt+F5
> sobre `tests/`) para confirmar que coinciden; si algo no cuadra,
> avísame. Los casos **INT-01** y **SIS-01** son manuales y requieren
> que tú los ejecutes jugando el proyecto — quedan documentados con su
> objetivo y resultado esperado, con la sección de resultados en
> blanco para que la completes.

---

## Caso de prueba: UNI-01 — Selección del mejor cupón

- **Tipo:** Unitaria
- **Objetivo:** Verificar que `GlobalManager.get_best_coupon(subtotal)` seleccione correctamente el mejor cupón disponible según el subtotal de la compra.

**Casos de prueba:**

- **Caso 1 — Cupón válido**
  - **Entrada:** Un cupón de valor 2000 y compra mínima de 10000. Subtotal: 12000.
  - **Resultado esperado:** Se devuelve el cupón de valor 2000.

- **Caso 2 — Compra inferior al mínimo**
  - **Entrada:** Un cupón de valor 2000 y compra mínima de 10000. Subtotal: 9999.
  - **Resultado esperado:** Se devuelve un diccionario vacío `{}`.

- **Caso 3 — Selección del cupón de mayor valor**
  - **Entrada:** Dos cupones: uno de valor 1000 y compra mínima de 5000; otro de valor 3000 y compra mínima de 10000. Subtotal: 12000.
  - **Resultado esperado:** Se devuelve el cupón de valor 3000.

### Resultado de la ejecución

- **Casos aprobados:** 3 de 3
- **Casos fallidos:** 0 de 3

**Conclusión:** `get_best_coupon()` cumple los tres casos evaluados: descarta cupones por debajo del mínimo, acepta el único cupón válido cuando corresponde, y elige el de mayor valor cuando hay varios aplicables. Automatizado en `tests/test_global_manager_cupones.gd`.

---

## Caso de prueba: UNI-02 — Total de accesorios (reto autónomo)

- **Tipo:** Unitaria
- **Objetivo:** Verificar que `GlobalManager._on_accessory_toggled()` + `_recalcular_total()` mantengan `precio_total` correcto al activar, combinar, desactivar o enviar un accesorio desconocido.

**Casos de prueba:**

- **Caso 1 — Accesorio válido activado (positivo)**
  - **Entrada:** `_on_accessory_toggled("Parabrisas", true)`.
  - **Resultado esperado:** `precio_total = 150000`.

- **Caso 2 — Varios accesorios activos (positivo compuesto)**
  - **Entrada:** `_on_accessory_toggled("Parabrisas", true)` seguido de `_on_accessory_toggled("Alforjas", true)`.
  - **Resultado esperado:** `precio_total = 450000`.

- **Caso 3 — Desactivar un accesorio activo (límite)**
  - **Entrada:** Activar "Parabrisas" y luego desactivarlo.
  - **Resultado esperado:** `precio_total` vuelve a `0`.

- **Caso 4 — Accesorio inexistente (negativo)**
  - **Entrada:** `_on_accessory_toggled("Sidecar", true)` (no existe en `precios_accesorios`).
  - **Resultado esperado:** `precio_total` sigue en `0` y `"Sidecar"` no aparece en `accesorios_activos`.

### Resultado de la ejecución

- **Casos aprobados:** 4 de 4
- **Casos fallidos:** 0 de 4

**Conclusión:** la función ignora correctamente accesorios desconocidos (con `push_warning`, sin afectar el total), suma varios accesorios activos y revierte el total al desactivarlos. Automatizado en `tests/test_global_manager_accesorios.gd`.

---

## Caso de prueba: INT-01 — Registro de un cupón obtenido

- **Tipo:** Integración
- **Objetivo:** Verificar que la señal `EventBus.coupon_obtained` comunique correctamente la obtención de un cupón desde el minijuego "Taller de Repuestos" y que `GlobalManager` lo registre (y lo persista en `save_data.json`, Laboratorio 7).

**Casos de prueba:**

- **Caso 1 — Recepción del evento**
  - **Condición inicial:** El proyecto está corriendo y la conexión `EventBus.coupon_obtained.connect(_on_coupon_obtained)` está activa (se hace en `GlobalManager._ready()`).
  - **Entrada:** Ganar el minijuego "Taller de Repuestos" (recolectar los repuestos objetivo antes de superar el límite de caídos).
  - **Resultado esperado:** `GlobalManager` recibe el evento y agrega el cupón a `coupons`.

- **Caso 2 — Conservación de los datos**
  - **Condición inicial:** Se ganó el minijuego al menos una vez.
  - **Resultado esperado:** El cupón registrado conserva su `value` (50.000 por defecto, ver `coupon_value` en `coupon_game.gd`) y su `minimum_purchase` (300.000 por defecto).

### Resultado de la ejecución

- **Casos aprobados:** _(pendiente — ejecútalo tú jugando el minijuego)_
- **Casos fallidos:** _(pendiente)_

**Detalle de los fallos:** _(completar si aplica)_

**Conclusión:** _(completar después de ejecutar: indica si el minijuego, el EventBus y GlobalManager se comunican correctamente)_

---

## Caso de prueba: SIS-01 — Obtención y persistencia de un cupón

- **Tipo:** Sistema
- **Objetivo:** Verificar el flujo completo de obtención, persistencia y uso de un cupón dentro del juego de motos.

**Casos de prueba:**

- **Caso 1 — Obtención de la recompensa**
  - **Entrada:** Iniciar el juego y completar correctamente el minijuego "Taller de Repuestos".
  - **Resultado esperado:** El jugador obtiene el cupón de recompensa.

- **Caso 2 — Persistencia**
  - **Entrada:** Cerrar y volver a abrir la aplicación.
  - **Resultado esperado:** El cupón sigue disponible (se lee desde `user://save_data.json`, ver ADR-004).

- **Caso 3 — Uso del cupón**
  - **Entrada:** Configurar la moto (color, accesorios, rines) y llegar a la factura con un subtotal que alcance el mínimo del cupón.
  - **Resultado esperado:** El cupón se aplica y el total final se calcula correctamente (subtotal − descuento).

- **Caso 4 — Persistencia del consumo**
  - **Entrada:** Confirmar la compra, cerrar y volver a abrir la aplicación.
  - **Resultado esperado:** El cupón consumido no vuelve a aparecer como disponible.

### Resultado de la ejecución

- **Casos aprobados:** _(pendiente — ejecútalo tú jugando el flujo completo)_
- **Casos fallidos:** _(pendiente)_

**Detalle de los fallos:** _(completar si aplica)_

**Conclusión:** _(completar después de ejecutar: indica si el flujo completo funciona correctamente)_
