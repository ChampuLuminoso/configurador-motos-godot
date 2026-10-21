# ADR-005: Catálogo dinámico de rines mediante Resource

* **Estado:** Aprobado
* **Fecha:** 30/10/2026
* **Autor:** Jorge Eliecer Montes Rodríguez

## Contexto

El Laboratorio 9 enseña a representar información mediante `Resource`
(en vez de botones fijos escritos a mano) y a generar la interfaz
automáticamente a partir de esa información, usando como ejemplo una
pizza dividida en dos mitades, cada una con su propio ingrediente
elegido de forma independiente.

El proyecto de motos no vende pizzas, así que fue necesario decidir a
qué parte del dominio aplicar este patrón.

## Decisión

Se traduce "dos mitades con ingrediente independiente" a **dos ruedas
(delantera y trasera) con su propio estilo de rin**, elegido de forma
independiente desde un catálogo:

- `RimData` (`Resource`): un estilo de rin — `id`, `display_name`,
  `texture`, `price`. Equivalente a `IngredientData` de la guía.
- `RimDatabase` (`Resource`): colección de `RimData`. Equivalente a
  `IngredientDatabase`.
- `GlobalManager.rims` expone el catálogo (`rim_database.tres`, con 4
  estilos: radios en negro/blanco y rin tapado en negro/blanco) sin
  almacenarlo de nuevo, igual que se hizo con los ingredientes en la
  guía.
- Una nueva pantalla (`wheel_customizer_panel.tscn`) genera un botón
  por cada rin del catálogo (`Parte 2-3` de la guía) y dos zonas
  seleccionables — `FrontWheel` / `RearWheel` — que reciben el rin
  elegido según cuál esté activa (`Parte 4`), con el mismo patrón de
  retroalimentación visual (`ColorRect` + `Tween`) y animación de
  cambio de textura (`Parte 5-6`) que la guía usa en las mitades de
  pizza.

Esta pantalla **no reemplaza** el configurador de color y accesorios
existente (Laboratorios 1-8): es una pantalla nueva y paralela,
siguiendo la misma idea de la guía de no modificar el sistema anterior
al incorporar uno nuevo.

### Precio de los rines en la factura

A diferencia del color (que no tiene costo en este proyecto), cada
`RimData` sí tiene `price`, porque mapea mejor con la estructura de
`IngredientData` de la guía y permite reutilizar `GlobalManager` para
sumarlo al total junto con los accesorios, en vez de crear un tercer
sistema de precios independiente.

## Consecuencias

### Positivas
- Agregar un rin nuevo (por ejemplo, "rin cromado") solo requiere crear
  un recurso `RimData` y añadirlo a `rim_database.tres` — ningún script
  ni escena cambia.
- El patrón de selección independiente por "mitad" de la guía se
  conserva fielmente, aplicado a un concepto que sí tiene sentido para
  una moto: rueda delantera y trasera pueden lucir distinto.

### Negativas / Costos
- Las imágenes de los 4 estilos de rin son generadas (`PIL`), no fotos
  reales — igual que `moto_base.png` en el Laboratorio 7, queda como
  pendiente reemplazarlas por arte real.

## Actualización (30/10/2026)

La primera versión puso la personalización de rines en una pantalla
nueva y separada (`wheel_customizer_panel.tscn`), siguiendo literalmente
el patrón de la guía de duplicar la pantalla de compra en vez de
modificar la existente.

Se decidió **fusionarla dentro de `configurator_panel.tscn`** (color +
accesorios + rines en una sola pantalla), porque para este proyecto de
práctica no tenía sentido de producto que el cliente tuviera que saltar
entre dos pantallas para ver el precio y la vista previa completos de
su moto. `WheelComposition` se conservó tal cual (`wheel_composition.gd`,
ahora con `class_name WheelComposition` para poder tiparlo desde
`configurator_panel.gd`) y se insertó como un nodo más dentro de
`PanelVista`, debajo de la imagen de la moto. La pantalla separada
(`wheel_customizer_panel.tscn/.gd`) y el botón de menú que apuntaba a
ella se eliminaron para no dejar dos caminos redundantes al mismo
resultado.
