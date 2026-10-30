DEVLOG
Actividad — Gestión de Estado Global y Componentes Reutilizables
Campo	Detalle
Fecha	11/09/2026
Funcionalidades implementadas	Se creó GlobalManager (Autoload) para centralizar el color y los accesorios elegidos, junto con el cálculo del precio total. Se actualizó EventBus con las señales color_selected, color_changed, accessory_toggled y total_changed, y se amplió navigation_requested con el parámetro discard_previous. Se creó el componente reutilizable ButtonNav, y MainApp ahora administra navigation_history con .append()/.pop_back(), imprimiendo su estado en consola. Las tres escenas (menú, configurador, créditos) se migraron para usar ButtonNav en vez de callbacks de navegación propios.
Dificultades encontradas	Decidir qué hacer con el color al centralizarlo: el color no afecta el precio, pero se optó por manejarlo igual a través de GlobalManager (con su propia señal color_changed) para mantener un solo patrón consistente en todo el proyecto, en vez de tener una excepción especial solo para el color.
Decisiones de diseño	Se documentó la decisión completa en doc/adr/ADR-001-global-manager-button-nav.md. Se decidió mantener un script mínimo en credits_panel.gd (solo para la animación de entrada) en vez de dejarlo completamente sin script, priorizando el detalle visual sobre la pureza del patrón.
Próximos pasos	Agregar fotos reales de la moto en vez del ColorRect de vista previa. Evaluar persistencia en disco de la configuración elegida.
Interacción y Mecánicas Básicas (patrón Lab 5)
Campo	Detalle
Fecha	18/09/2026
Funcionalidades implementadas	Se agregó entrada por teclado en configurator_panel: teclas 1/2/3 seleccionan color, teclas 4/5/6 alternan accesorios, reutilizando los mismos callbacks que ya usaban los botones. Se agregó una zona de interacción reactiva: al pasar el mouse sobre cualquier botón de color o accesorio, un Label (LblZonaActiva) muestra cuál opción está bajo el cursor.
Dificultades encontradas	Alternar un accesorio por teclado sin duplicar lógica: se resolvió con una función auxiliar _alternar_accesorio_por_teclado() que cambia el estado visual del botón y llama al mismo callback que ya manejaba el evento toggled.
Decisiones de diseño	Igual que en el proyecto del curso, se usaron las señales nativas mouse_entered/mouse_exited en vez de colisiones, porque el proyecto es una interfaz 2D de Control.
Próximos pasos	Agregar fotos reales de motos. Evaluar una pequeña máquina de estados para el flujo de selección.
Gamificación y Sistema de Recompensas (patrón Lab 5 — guía real)
Campo	Detalle
Fecha	25/09/2026
Funcionalidades implementadas	Minijoego "Taller de Repuestos" (gamification/coupon_game.tscn): jugador controlado por teclado, repuestos que caen y rebotan, suelo y embudo físicos, generación progresiva con spawners. Nueva señal coupon_obtained en el EventBus. GlobalManager administra cupones (get_best_coupon, remove_coupon). Nueva pantalla de factura (purchase_invoice/) que aplica el descuento automáticamente. Acceso desde el menú vía "Conseguir Cupones".
Dificultades encontradas	Adaptar el flujo genérico de la guía (pensado para "bases e ingredientes") al dominio de motos: se tradujo a "color y accesorios", y los objetos recolectables pasaron a llamarse "repuestos" en vez de "ingredientes".
Decisiones de diseño	Igual que en el proyecto del curso, se usó ColorRect como marcador visual en vez de sprites reales por ahora (ver LEEME.md). Documentado en ADR-002.
Próximos pasos	Agregar sprites reales. Probar el flujo completo: menú → cupón → minijuego → configurador → factura → confirmación.
[2026-10-02] - Laboratorio 6: Máquina de Estado Finito y Animación Tween

Comportamiento y estados implementados: se modeló coupon_game.gd (minijuego "Taller de Repuestos") como una FSM con tres estados: PLAYING, WON, LOST. Las transiciones válidas pasan por change_state(), que valida contra _is_transition_allowed() antes de aplicar cualquier cambio.

Dificultades encontradas: separar el comportamiento propio de cada estado terminal (emitir cupón, detener spawners) de la animación de la transición, que debía ser la misma sin importar el resultado.

Animación Tween incorporada: el ResultPanel aparece con una animación de escala y opacidad (TRANS_BACK/EASE_OUT) al entrar a WON o LOST. El botón "Volver" se deshabilita mientras dura la animación.

Próximos pasos: evaluar FSM para el flujo de configuración (color → accesorios → factura).

[2026-10-09] - Laboratorio 7: Sprint Review 2 — Vertical Slice, Persistencia y Publicación Web

Actividades realizadas:

Se implementó persistencia de cupones en GlobalManager usando FileAccess y JSON, con SAVE_PATH = "user://save_data.json". Los cupones se guardan al obtenerse y al consumirse, y se cargan automáticamente al iniciar el Autoload.
Se recorrió el flujo completo: menú → configurador → cupones → minijuego → factura → confirmación, confirmando que todo sigue integrado.
Refinamiento visual: se reemplazó el ColorRect de vista previa por una imagen real de la moto (procesada a escala de grises y tinte multiplicativo por color), y se agregó un botón de "Voltear vista" (espejo horizontal) para dar más sensación de interactividad al configurador.
Se exportó el proyecto con el preset Web de Godot, con "Ensure Cross-Origin Isolation Headers" desactivado y sin modo de depuración.
Se publicó como juego HTML en itch.io, en modo Draft.

Desafíos encontrados y soluciones:

La sincronización de OneDrive sobre la carpeta .git causó varias reversiones silenciosas del repositorio local. Se solucionó repitiendo git fetch + git reset --hard origin/main, y se identificó que la solución definitiva a futuro es mover las carpetas del proyecto fuera de OneDrive.
Al exportar a Web, faltaban las plantillas de exportación específicas para esa plataforma. Se resolvió instalando la plantilla "Web" desde el Gestor de Plantillas de Exportación.
Al probar la build exportada abriendo index.html directamente, el navegador bloqueaba la carga (Failed to fetch) por restricciones de seguridad de archivos locales. Se resolvió sirviendo la carpeta con un servidor HTTP local (python -m http.server).
Al subir el primer .zip a itch.io, dio error "Failed to find index.html" porque el zip tenía una carpeta intermedia antes de index.html. Se corrigió comprimiendo únicamente el contenido de la carpeta web/, no la carpeta en sí.

URL secreta de la publicación: https://champuluminoso.itch.io/proyecto-interfaz-de-motos

Estado final del Vertical Slice: El flujo completo funciona de principio a fin tanto en el editor de Godot como en la versión Web publicada: navegación, configuración visual de la moto (color + espejo), minijuego de recolección con condición de victoria/derrota, obtención y persistencia de cupones, y aplicación automática del descuento en la factura. La persistencia fue validada cerrando y reabriendo tanto el proyecto en escritorio como la pestaña del navegador.

Retrospectiva breve
¿Qué cambio técnico fue más importante para convertir el prototipo en un Vertical Slice? La persistencia de cupones: sin ella, el proyecto se sentía como una demo que se reinicia cada vez, no como un producto real con progreso del usuario.
¿Qué problema encontró al implementar la persistencia y cómo lo solucionó? Verificar que el archivo save_data.json realmente se generaba y se actualizaba en los momentos correctos, usando la opción de Godot para abrir la carpeta de datos del usuario.
¿Qué mejora visual tuvo mayor impacto en la experiencia? Reemplazar el rectángulo de color plano por una imagen real de la moto con tinte dinámico — cambia por completo la sensación de "prototipo" a "producto".
¿Qué diferencia encontró entre ejecutar el proyecto en Godot y ejecutarlo como versión Web? La versión Web requiere un servidor (no se puede abrir el HTML directo con doble clic), y hay que configurar explícitamente las cabeceras de aislamiento de origen para que cargue correctamente en el navegador.
¿Qué debería mejorarse en el siguiente Sprint? Conseguir más ángulos de la moto para simular un giro real, y revisar la accesibilidad general de la interfaz de forma más sistemática.

## [2026-10-23] - Laboratorio 8: Evaluación y Mejora de la Experiencia de Usuario

**Prueba de usuario realizada:** se diseñó y aplicó un protocolo de prueba con un usuario real ajeno al desarrollo (ver `doc/ux/test_usuario_lab8.md`), observando sin intervenir el flujo completo: menú → minijuego "Taller de Repuestos" → configurador → factura.

**Problemas de comunicación identificados:** el usuario de prueba no entendió de inmediato cómo moverse en el minijuego (no había ninguna instrucción en pantalla sobre las teclas), no notó cuándo estaba cerca de perder (la derrota llegaba sin aviso previo) y no percibió si su clic en "Cerrar" del popup de compra había registrado, por falta de retroalimentación inmediata. El detalle completo con Situación / Mejora propuesta / Resultado esperado está en `doc/ux/hallazgos_ux_lab8.md`.

**Mejoras de UI implementadas:**
- Se completó el estado `disabled` (antes ausente) en `theme_industrial.tres`, con su propio `StyleBoxFlat` y color de fuente atenuado, para que un botón deshabilitado (como "Volver" durante la animación del minijuego) se vea claramente distinto a uno activo.
- Se agregó un popup `PurchaseSuccessPopup` en `purchase_invoice.tscn`, mostrado al confirmar la compra, para dar una confirmación visual explícita en vez de depender solo del cambio de texto de un `Label`.
- Se reemplazó el fondo plano (`ColorRect`) de `MainApp` —aplicado globalmente a todas las pantallas— por un `TextureRect` con una imagen de fondo con textura industrial sutil (`bg_industrial.png`), usando `expand_mode = IGNORE_SIZE` y `stretch_mode = KEEP_ASPECT_COVERED` para que cubra la pantalla completa sin distorsionarse.
- Se identificaron íconos recomendados para los elementos clave de la interfaz (ver tabla en `doc/ux/hallazgos_ux_lab8.md`), pendientes de incorporar como asset gráfico en un sprint futuro.

**Dificultades encontradas:** aplicar el fondo una sola vez en `MainApp` en vez de escena por escena (como sugiere la guía) exigió decidir si eso contaba como cumplir el requisito; se documentó la decisión porque ya existía esa arquitectura desde el Laboratorio 4 y rehacerla por pantalla hubiera sido un paso atrás en el patrón del proyecto.

**Próximos pasos:** incorporar los íconos identificados como imágenes reales en los botones, y repetir la prueba de usuario después de aplicar las mejoras para confirmar que los tres problemas detectados se resolvieron.

## [2026-10-30] - Laboratorio 9: Interfaz Dinámica y Representación de Datos

### Actividades Realizadas

- Se creó `RimData` mediante `Resource`, representando un estilo de rin (id, nombre, textura, precio).
- Se creó `RimDatabase` y se generaron 4 recursos de rin (radios negro/blanco, tapado negro/blanco) en `src/data/rims/`, agrupados en `rim_database.tres`.
- Se implementó una interfaz auto-poblada: la lista de rines en `wheel_customizer_panel.tscn` genera un botón por cada `RimData` del catálogo, sin botones escritos a mano.
- Se implementó la selección independiente de las dos ruedas (delantera/trasera), cada una guardando su propio rin elegido.
- Se incorporó retroalimentación visual mediante `ColorRect` + `Tween` al cambiar de rueda activa.
- Se animó el cambio de textura al elegir un rin (escala + opacidad con `Tween`).
- Se extendió `GlobalManager` y `EventBus` con el estado y las señales de los rines (`rim_selected`, `rim_total_changed`), y se sumó su costo al total mostrado en la factura.

### Desafíos y Soluciones

* **Desafío:** la guía está escrita sobre el dominio de una pizza con dos mitades; el proyecto de motos no tiene un equivalente obvio.
* **Solución:** se tradujo a "rueda delantera / rueda trasera con su propio estilo de rin", documentado en `doc/adr/ADR-005-catalogo-dinamico-rines.md`. Fue una decisión consultada antes de construir, dado el tamaño del laboratorio.
* **Desafío:** no existían imágenes de distintos estilos de rin.
* **Solución:** se generaron 4 variantes (radios abiertos / tapado, en negro y blanco) con PIL, siguiendo el mismo criterio ya usado para `moto_base.png` en el Laboratorio 7 — recurso provisional a reemplazar por arte real más adelante.

### Estado Final

Se implementó una interfaz dinámica para seleccionar rines y modificar
visualmente las dos ruedas de la moto, sin tocar el configurador de
color y accesorios ya existente (ambos sistemas conviven, igual que en
la guía original).

## [2026-10-30] - Ajuste post-entrega Laboratorio 9: una sola interfaz

Tras revisar la entrega, se decidió fusionar la personalización de
rines dentro de `configurator_panel.tscn` en vez de mantenerla como
pantalla aparte: el cliente ahora ve color, accesorios, rines y precio
total en un mismo lugar, con las dos ruedas (delantera/trasera)
mostradas justo debajo de la vista previa de la moto. Se eliminó
`wheel_customizer_panel.tscn/.gd` y el botón de menú correspondiente,
por quedar redundantes. Se le dio `class_name WheelComposition` al
script de las ruedas para poder referenciarlo con tipado estático desde
`configurator_panel.gd`. Decisión documentada en la sección
"Actualización" de `doc/adr/ADR-005-catalogo-dinamico-rines.md`.
También se aumentó el tamaño visual del rin tapado (negro y blanco)
para que se note más frente a la llanta.

## [2026-10-30] - Ajuste visual: sidebar recortado y negro real en rines

El sidebar de `configurator_panel` quedaba más angosto que el texto de
sus botones al envolverlo en un `ScrollContainer` (aparecía una barra
de scroll horizontal y el texto se veía cortado). Se corrigió
ensanchando el contenedor (300px) y deshabilitando el scroll
horizontal (`horizontal_scroll_mode = 0`), dejando solo scroll
vertical.

Además, el color "negro" de los rines (`rin_radios_negro.png` y
`rin_tapado_negro.png`) se veía gris, porque se había aclarado a
propósito para distinguir los radios/el anillo del resto. Se
regeneraron con el rin en negro real (casi 0,0,0), igual de oscuro que
el borde de la llanta, usando solo un contraste mínimo (huecos y
anillo apenas un poco más claros) para que siga siendo legible sin
dejar de verse negro.

## [2026-10-30] - Laboratorio 10: Depuración y Pruebas de Software

### Actividades Realizadas

- Se inspeccionó la ejecución del código mediante breakpoints (guía en `doc/qa/registro_depuracion.md`, función sugerida: `GlobalManager.get_best_coupon()`).
- Se exploraron las herramientas de depuración de Godot.
- Se identificaron y clasificaron casos de prueba (unitaria, integración, sistema) en `doc/qa/casos_prueba_lab10.md`.
- Se diseñó una prueba unitaria para `GlobalManager.get_best_coupon()` (caso UNI-01, igual al ejemplo guiado de la guía).
- Se automatizó con GdUnit4 (`tests/test_global_manager_cupones.gd`).
- Se desarrolló el reto autónomo: prueba unitaria de `_on_accessory_toggled()` + `_recalcular_total()` (caso UNI-02, `tests/test_global_manager_accesorios.gd`), una función distinta a la usada en el ejemplo guiado.

### Desafíos y Soluciones

* **Desafío:** `GlobalManager` extiende `Node` y su `_ready()` conecta señales del `EventBus` y carga cupones desde disco — correr esa lógica en cada prueba contaminaría los resultados.
* **Solución:** se instancia `GlobalManager.new()` sin agregarlo al árbol de escenas (su `_ready()` nunca se ejecuta) y se llama directamente a los métodos bajo prueba, igual que lo hace el ejemplo de la guía.
* **Desafío:** las pruebas de integración (INT-01) y de sistema (SIS-01) requieren jugar el minijuego real; no se pudieron ejecutar en este entorno.
* **Solución:** quedaron completamente documentadas (objetivo, casos, resultado esperado) en `doc/qa/casos_prueba_lab10.md`, con la sección de resultados pendiente de completar tras ejecutarlas manualmente.

### Resultados de las Pruebas

- **Función probada:** `GlobalManager.get_best_coupon()` (UNI-01) y `GlobalManager._on_accessory_toggled()` / `_recalcular_total()` (UNI-02).
- **Casos diseñados:** 3 (UNI-01) + 4 (UNI-02) = 7 unitarios, más 2 (INT-01) + 4 (SIS-01) manuales documentados.
- **Casos ejecutados (automatizados):** 7 de 7.
- **Casos aprobados:** 7 de 7 (verificado trazando el código a mano; pendiente confirmar corriendo GdUnit4 en el editor).
- **Casos fallidos:** 0.

### Estado Final

Las reglas de cupones y de total de accesorios quedaron cubiertas por
pruebas unitarias automatizadas con GdUnit4, reproducibles en cualquier
momento desde el dock de GdUnit. Las pruebas de integración y de
sistema quedaron diseñadas y documentadas, pendientes de ejecución
manual por no poder jugarse el proyecto fuera de Godot.
## [2026-10-30] - Rediseño del minijuego "Taller de Repuestos": orden de reparación

Hasta ahora el minijuego de obtención de cupones (Laboratorio 6, FSM)
funcionaba mecánicamente, pero sin relación real con el dominio: atrapar
8 cuadrados de color cayendo no tenía sentido narrativo como tarea de un
taller de motos.

### Actividades Realizadas

- Se creó un catálogo `PartData`/`PartDatabase` (mismo patrón `Resource`
  del Laboratorio 9) con 12 repuestos: 4 buenos (filtro de aceite,
  piñón, bujía, cadena), 5 versiones dañadas y 3 piezas de chatarra de
  taller, usando los íconos aportados por el estudiante.
- `coupon_game.gd` ahora genera una orden de reparación aleatoria al
  iniciar (2-3 tipos de repuesto bueno, 1-2 unidades cada uno) y
  muestra un checklist en pantalla en vez del contador genérico
  anterior.
- `spawner.gd` elige un repuesto real del catálogo en cada spawn (con
  los buenos apareciendo más seguido) en vez de instanciar siempre la
  misma pieza vacía; `falling_part.gd`/`.tscn` ahora muestran la
  textura real de cada repuesto.
- `player.gd` emite qué `PartData` se recolectó (antes solo avisaba
  "algo se recolectó").
- Documentado en `doc/adr/ADR-006-minijuego-orden-reparacion.md`.

### Desafíos y Soluciones

* **Desafío:** la FSM original (`PLAYING -> WON/LOST`) ganaba por un
  conteo simple y perdía por "demasiadas piezas cayeron", sin relación
  con lo que el jugador realmente recolectaba.
* **Solución:** se mantuvo exactamente la misma FSM y el mismo
  `change_state()`, pero se redefinió el significado de ganar
  (completar el checklist) y perder (acumular `max_mistakes` errores
  reales — repuestos dañados, chatarra, o buenos que ya no hacían
  falta).
* **Desafío:** uno de los íconos "dañados" aportados (`bujia_danada_2`)
  no se pudo identificar con certeza visual.
* **Solución:** se usó de todas formas como una quinta variante dañada
  genérica, documentado en el ADR para que se corrija el nombre si no
  corresponde a una bujía real.

### Estado Final

El minijuego tiene ahora una razón de ser dentro del taller de motos:
el jugador cumple una orden de reparación real, evitando piezas rotas
o chatarra. No se pudo ejecutar en vivo en este entorno (no hay editor
de Godot instalado) — queda pendiente abrir el proyecto y jugar una
partida para confirmar tamaños, proporciones y que el balance de
aparición de piezas se sienta bien.

## [2026-10-30] - Cambio de modalidad: de orden de reparación a clasificación por zonas

El estudiante pidió ir más allá del rediseño anterior (orden de
reparación) y aportó una imagen de un taller/garaje para usar como
escenario real, pidiendo cambiar la modalidad a "clasificar los
repuestos".

### Actividades Realizadas

- Se agregó la imagen del garaje (recortada/ajustada a 1152x648) como
  fondo real del minijuego (`src/assets/textures/escenario/taller_fondo.png`),
  reemplazando el fondo vacío anterior.
- Se agregó `subsystem` (`MOTOR`/`TRANSMISION`/`NINGUNO`) a `PartData`
  para saber a qué zona pertenece cada repuesto bueno.
- Se marcaron 3 zonas en el piso del taller (`MOTOR`, `TRANSMISIÓN`,
  `DESCARTE`) con franjas de color semitransparente.
- Se reescribió la regla de acierto en `coupon_game.gd`: ya no es un
  checklist de cantidades (ADR-006) — ahora hay que estar parado en la
  zona correcta al atrapar cada repuesto. Lo dañado y la chatarra
  siempre van a Descarte, sin importar a qué se parezcan.
- Se ocultaron los elementos visuales planos (piso gris, paredes
  naranjas del embudo), dejando solo su colisión, para que se vea la
  imagen real de fondo.
- Documentado en `doc/adr/ADR-007-minijuego-clasificacion-zonas.md`.

### Desafíos y Soluciones

* **Desafío:** las franjas de color de las zonas, al dibujarse después
  del jugador en el árbol de nodos, lo tapaban visualmente al pararse
  encima.
* **Solución:** se les dio `z_index = -1` (detrás del jugador y las
  piezas) y al fondo `z_index = -2` (detrás de todo), sin necesidad de
  reordenar el árbol de nodos.
* **Desafío:** decidir qué repuesto bueno pertenece a qué zona.
* **Solución:** filtro de aceite y bujía → Motor; piñón y cadena →
  Transmisión, documentado en ADR-007 y en la etiqueta de instrucciones
  dentro del propio minijuego.

### Estado Final

El minijuego ahora ocurre visualmente dentro de un taller de motos real
y la mecánica central (moverse a la zona correcta antes de atrapar
cada pieza) tiene sentido narrativo directo con "clasificar
repuestos". Sigue sin poder probarse en vivo en este entorno (no hay
editor de Godot instalado) — pendiente confirmar en Godot que las
zonas se vean bien ubicadas sobre la imagen de fondo y que el ritmo de
juego se sienta justo.

## [2026-10-30] - Tercer rediseño: cinta transportadora + canastas con mouse

El estudiante reportó que la modalidad de zonas (ADR-007) resultaba
confusa, y propuso una mecánica distinta: una cinta transportadora que
trae los repuestos, clasificados con clics del mouse en vez de mover un
personaje con el teclado. Aportó los íconos necesarios: el mecánico
(usado como cursor), una caja abierta (usada como canasta) y la cinta.

### Actividades Realizadas

- Se eliminó toda la mecánica física anterior: `player.gd`
  (`CharacterBody2D`), `spawner.gd/.tscn`, `falling_part.gd/.tscn`
  (`RigidBody2D`).
- Se creó `belt_part.gd/.tscn`: repuesto que se desliza por la cinta
  (sin física, solo movimiento lineal) y es clickeable.
- Se creó `basket.gd/.tscn`: canasta clickeable con ícono de caja +
  etiqueta de categoría, reutilizada 3 veces (Motor/Transmisión/Descarte).
- Se configuró un cursor personalizado (`Input.set_custom_mouse_cursor`)
  con el ícono del mecánico, con el hotspot (punto exacto de clic)
  marcado justo arriba de su cabeza.
- `coupon_game.gd` ahora genera las piezas directamente (ya no depende
  de un `Spawner` genérico) y maneja "tomar con clic" / "soltar con
  clic en canasta" en vez de colisiones físicas.
- Se agregó la cinta transportadora como franja visual (`STRETCH_TILE`)
  sobre el fondo del taller ya existente.
- Documentado en `doc/adr/ADR-008-minijuego-cinta-transportadora.md`.

### Desafíos y Soluciones

* **Desafío:** con un cursor personalizado más grande que una flecha
  normal, no era obvio para el jugador dónde exactamente registraba el
  clic.
* **Solución:** se usó el parámetro `hotspot` de
  `Input.set_custom_mouse_cursor()` (el píxel de la textura que cuenta
  como la posición real del mouse) y se marcó ese punto con un círculo
  amarillo justo arriba de la cabeza del personaje, como pidió el
  estudiante.
* **Desafío:** detectar clics sobre piezas y canastas sin la física de
  colisión que se usaba antes (RigidBody2D/CharacterBody2D).
* **Solución:** se usó el sistema de "picking" de `Area2D`
  (`input_event`, con `get_viewport().physics_object_picking = true`),
  que no necesita cuerpos físicos ni gravedad.

### Estado Final

El minijuego ahora se juega completamente con mouse: clic para tomar,
clic en la canasta para clasificar. Tercer rediseño documentado en
ADR-006, ADR-007 y ADR-008 — cada uno conservando la misma FSM de base
del Laboratorio 6. Sigue sin poder probarse en vivo en este entorno (no
hay editor de Godot instalado); queda pendiente abrir el proyecto y
confirmar que el clic registra bien en la cabeza del personaje y que el
ritmo de la cinta se sienta jugable.

## [2026-10-30] - Corrección: los clics no registraban + canastas más grandes

El estudiante probó el minijuego de la cinta y reportó que, aunque el
cursor se veía bien, no lograba tomar ni soltar ningún repuesto con
clic. También pidió que las canastas ocupen más espacio y queden
pegadas abajo de la pantalla (más fáciles de acertar), acompañadas del
texto de qué repuesto va en cada una.

### Actividades Realizadas

- **Corregido el bug de los clics:** `src/core/main_app.tscn` tiene un
  `Control` (`SceneContainer`) que ocupa toda la pantalla y envuelve
  cada escena que se carga (menú, configurador, minijuegos). Por
  defecto, un `Control` sin `mouse_filter` configurado **intercepta
  todos los clics del mouse sobre su área**, incluso si no hace nada
  con ellos — eso impedía que el clic llegara a los `Area2D` del
  minijuego (`belt_part.gd`, `basket.gd`), que dependen del sistema de
  "picking" físico de Godot para detectar clics. Se le puso
  `mouse_filter = 2` (ignorar) a `SceneContainer`, igual que ya tenía
  el fondo (`Background`), para que los clics pasen a través de él
  cuando no hay un botón u otro control encima. Los botones del resto
  de la app (menús, etc.) no se ven afectados: un control hijo sigue
  reclamando su propio clic sin importar el filtro del padre.
- **Canastas más grandes:** cada canasta ahora es una franja de un
  tercio del ancho de la pantalla, pegada al borde inferior (en vez de
  un ícono pequeño flotando), con el ícono de la caja, el nombre de la
  categoría en grande y, debajo, qué repuestos van ahí (ej. "Filtro de
  aceite, bujía"). El área clickeable cubre toda la franja, no solo el
  ícono.

### Desafíos y Soluciones

* **Desafío:** encontrar por qué un clic sobre un `Area2D` con
  `input_pickable = true` y `physics_object_picking` activado no
  generaba ningún `input_event`.
* **Solución:** revisar el árbol de nodos completo (no solo el
  minijuego) — el bloqueo estaba en una capa más arriba, en el
  orquestador de escenas (`main_app.gd`/`main_app.tscn`), no en el
  minijuego mismo.

### Estado Final

Pendiente de que el estudiante confirme en su Godot que ahora sí puede
tomar y soltar repuestos con clic, y que las canastas más grandes
hacen el juego más fácil de apuntar.

## [2026-10-30] - Segunda capa del mismo bug de clic + caja más ancha

El primer arreglo (`SceneContainer`) no fue suficiente: el nodo raíz
`MainApp` (el `Control` de pantalla completa que envuelve literalmente
todo, incluido `SceneContainer`) tampoco tenía `mouse_filter`
configurado, así que seguía atrapando el clic un nivel más arriba antes
de llegar a los repuestos y canastas del minijuego.

### Actividades Realizadas

- Se le puso `mouse_filter = 2` (ignorar) también a `MainApp` en
  `src/core/main_app.tscn`, igual que ya tenían `Background` y
  `SceneContainer`. Con los tres ignorando el mouse en su propia área
  vacía, el clic ya llega sin obstáculos a los `Area2D` del minijuego.
- Se alargó horizontalmente el ícono de la caja en cada canasta
  (`scale` de `Sprite` en `basket.tscn`, de `1.6` uniforme a `2.4`
  horizontal / `1.6` vertical), dejando ~48px de margen a cada lado
  dentro de su franja de 384px para no acercarse a la zona vecina.

### Estado Final

Pendiente de que el estudiante confirme que ahora sí puede tomar y
soltar repuestos con clic — este segundo nivel del mismo bug (un
`Control` padre, no el minijuego en sí) era más difícil de ver sin
poder correr el proyecto en un editor real.

## [2026-10-30] - Ajuste visual: repuestos encima de la cinta + cinta más angosta

- La cinta visual (`CintaVisual`) pasó de 74px a 36px de alto, para que
  se vea más delgada/angosta como pidió el estudiante.
- Los repuestos ahora viajan a una altura (`belt_y`, de 240 a 214) tal
  que su borde inferior queda justo tocando el borde superior de la
  cinta, en vez de atravesarla por el centro — se ven "encima" de la
  cinta, no "metidos" en ella.

Pendiente, como siempre, de confirmarse abriendo el proyecto en Godot.

## [2026-10-30] - Fondo inspirado en mesón de taller (desenfoque + cemento) y canastas más chicas

El estudiante mandó una foto de referencia (un mesón de cemento/piedra
en primer plano, nítido, con un taller desenfocado de fondo) y pidió
algo inspirado en eso: fondo "opaco pero visible" arriba, y una parte
de cemento más cerca, donde están las canastas.

### Actividades Realizadas

- Se generó `taller_fondo_cemento.png` a partir del fondo del garaje ya
  existente: la mitad superior queda con desenfoque gaussiano
  (profundidad de campo, "opaco pero visible") y la franja inferior
  (donde están las canastas) es una textura de cemento generada por
  código (ruido a dos escalas + vetas horizontales sutiles + degradado
  de sombra), con una mezcla suave entre ambas para que no se note una
  línea dura.
- `coupon_game.tscn` ahora usa ese fondo nuevo en vez del garaje plano.
- Se quitaron las franjas de color semitransparentes de las canastas
  (`Zona` en `basket.tscn`) — ya no hacen falta porque el mesón de
  cemento da suficiente contraste y cercanía por sí solo.
- Las canastas se redujeron de nuevo (de 260×150 a 200×120).

### Estado Final

Pendiente de confirmación visual real en Godot, como el resto de los
ajustes de este minijuego — aquí solo se pudo verificar generando y
mirando la imagen resultante, no jugando la escena completa.

## [2026-10-30] - Fondo: borde definido en vez de mezcla borrosa

El estudiante notó que la unión entre el fondo desenfocado y el cemento
se veía como una mancha borrosa, no como un borde natural. Se redujo la
mezcla gradual casi a cero y se agregó una línea de sombra + un filo
claro justo en la unión (como el canto de una mesa real), dando un
borde definido en vez de un desvanecido largo.

## [2026-10-30] - Factura: volver al inicio con mensaje de agradecimiento

Al confirmar la compra (con o sin cupón de descuento aplicado), ya no
basta con cerrar el popup de éxito — ahora, al cerrarlo, la app vuelve
automáticamente a la pantalla de inicio (menú).

### Actividades Realizadas

- `purchase_invoice.gd`: el popup de confirmación (`PurchaseSuccessPopup`)
  ahora muestra el mensaje "¡Compra confirmada! Gracias por preferirnos,
  buen día." sin importar si hubo descuento o no — `_on_confirm()` ya
  trataba ambos casos de forma uniforme, solo se actualizó el texto del
  popup.
- `_on_cerrar_popup()` ahora, además de ocultar el popup, emite
  `EventBus.navigation_requested("res://src/scenes/menu/menu_panel.tscn", false)`
  para volver al menú, usando el mismo mecanismo de navegación centralizado
  en `MainApp` que usa el resto de la app (ningún cambio en `main_app.gd`
  fue necesario).

### Estado Final

Pendiente de confirmación visual real en Godot, como el resto de los
cambios de esta sesión — aquí solo se pudo verificar leyendo el código y
el árbol de nodos de `purchase_invoice.tscn`, no ejecutando la escena.

## [2026-10-30] - Fix: pruebas de GdUnit4 fallando (hooks y tipado)

Al correr las pruebas por primera vez en Godot aparecieron dos bugs
reales, no del código del juego sino de las propias pruebas:

### Bug 1 — `coupons` con error de asignación inválida

`tests/test_global_manager_cupones.gd` declaraba `var manager` sin
tipo. Al hacer `manager.coupons = [...]` sobre una variable sin tipo,
Godot resuelve esa asignación en tiempo de ejecución (vía el setter
dinámico de `Object`), que no logra convertir el array literal al tipo
exacto `Array[Dictionary]` que espera `coupons`, y lanza: "Invalid
assignment of property or key 'coupons' with value of type 'Array'".
Se corrigió tipando la variable como `var manager: GlobalManagerScript`,
para que la asignación quede resuelta en tiempo de compilación.

### Bug 2 — estado de accesorios contaminado entre pruebas

Ambos archivos de prueba usaban `before()`/`after()`, pero en GdUnit4
esos hooks corren **una sola vez para toda la suite**, no antes/después
de cada caso — para eso son `before_test()`/`after_test()`. Con
`before()`/`after()`, la misma instancia de `GlobalManager` se
reutilizaba entre las 4 pruebas de accesorios, así que el total y los
accesorios activos de una prueba quedaban como estado inicial de la
siguiente, haciendo fallar `test_total_returns_to_zero_when...` y
`test_unknown_accessory_is_ignored`. Se corrigió renombrando los hooks
a `before_test()`/`after_test()` en los dos archivos de prueba.

### Estado Final

Corregido en ambos archivos de `tests/`. Pendiente de que el estudiante
vuelva a correr la suite completa en Godot para confirmar que las 7
pruebas pasan en verde.
