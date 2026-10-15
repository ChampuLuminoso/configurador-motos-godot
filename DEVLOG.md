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