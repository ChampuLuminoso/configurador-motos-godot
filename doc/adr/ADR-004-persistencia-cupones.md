# ADR-004: Persistencia de cupones con FileAccess y JSON

* **Estado:** Aprobado
* **Fecha:** 09/10/2026
* **Autor:** Jorge Eliecer Montes Rodríguez

## Contexto

`GlobalManager.coupons` vivía únicamente en memoria. Al cerrar el
proyecto, cualquier cupón ganado en el minijuego se perdía.

## Decisión

Se agrega persistencia usando `FileAccess` y `JSON`, sin librerías
externas: `SAVE_PATH = "user://save_data.json"`, `save_coupons()` y
`load_coupons()`. El guardado se dispara en los dos únicos puntos donde
la colección de cupones cambia: al obtenerse (`_on_coupon_obtained`) y
al consumirse (`remove_coupon`). La carga ocurre una sola vez, en
`_ready()`, antes de cualquier otra lógica del Autoload.

## Consecuencias

### Positivas
- Los cupones sobreviven a cerrar y reabrir el proyecto.
- `user://` funciona igual en escritorio y en la versión Web del
  proyecto, sin cambiar código.

### Negativas / Costos
- El archivo no está cifrado; aceptable para un proyecto académico.
