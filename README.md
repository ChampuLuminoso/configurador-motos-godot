# Configurador de Motos
**Proyecto personal de práctica — Producción de Videojuegos 2026**

## 🏷️ Nombre del Proyecto
Configurador de Motos — Prototipo Interactivo 2D

## 📝 Descripción del Proyecto
Este repositorio contiene un prototipo interactivo inspirado en configuradores comerciales de motocicletas (como el "Make It Yours" de Royal Enfield). El proyecto aplica, sobre un caso práctico distinto al del curso, la misma arquitectura de software vista en los Laboratorios 1 a 4: navegación desacoplada mediante un Event Bus, estado global centralizado, y componentes de interfaz reutilizables, todo desarrollado en Godot Engine.

## 🎯 Objetivo del Software Interactivo
Permitir que el usuario configure visualmente una motocicleta —eligiendo color y accesorios— y vea el precio total actualizarse en tiempo real, mientras navega entre un menú principal, el configurador y una pantalla de créditos. El proyecto sirve como ejercicio personal para trasladar conceptos de arquitectura de software a un dominio distinto al del proyecto integrador del curso.

## 📸 Captura de Pantalla del Estado Actual
> _Agrega aquí una captura del menú principal en ejecución y guárdala como
> `doc/screenshots/estado_actual.png`. Luego inserta:_
> `![Estado actual del proyecto](doc/screenshots/estado_actual.png)`

## 📂 Estructura de Directorios del Repositorio
El proyecto sigue una arquitectura modular con co-localización estricta
(cada escena vive junto a su script controlador, salvo Créditos, que
conserva un script mínimo únicamente para su animación de entrada):

```
src/
├── core/
│   ├── event_bus.gd            <- Autoload "EventBus" (Observer/Singleton)
│   ├── global_manager.gd       <- Autoload "GlobalManager"
│   ├── main_app.tscn           <- Escena principal (orquestador)
│   └── main_app.gd
├── scenes/
│   ├── menu/                   <- Menú principal
│   ├── configurator/           <- Configurador de color y accesorios
│   └── credits/                <- Créditos
├── components/
│   └── navigation/
│       └── button_nav.tscn     <- Botón de navegación reutilizable
└── assets/
    └── ui/
        └── theme_industrial.tres <- Tema visual (grises + naranja)
```

## 🧩 Arquitectura de Navegación Desacoplada
La navegación entre pantallas se resuelve mediante un **Event Bus global**
(Autoload `EventBus`) que centraliza la comunicación siguiendo el patrón
Observer. Cada panel emite `navigation_requested(target_scene,
discard_previous)` y `MainApp` es el único responsable de instanciar y
liberar escenas de forma segura, manteniendo además una pila
`navigation_history` que registra la secuencia de pantallas visitadas.

## 🧠 Estado Global Centralizado (GlobalManager)
Ningún panel calcula ni almacena datos de negocio localmente.
`GlobalManager` (Autoload) centraliza el color elegido, los accesorios
activos y el precio total en estructuras de datos propias, escucha las
señales `color_selected` y `accessory_toggled` del EventBus, y notifica
el resultado mediante `color_changed` y `total_changed`. La interfaz del
configurador solo emite intenciones y reacciona de forma pasiva a esas
señales.

## 🧩 Componentes Reutilizables
La lógica de navegación se extrae a `src/components/navigation/`. El
componente `button_nav.tscn` es un `Button` con las variables exportadas
`target_scene` (selector de archivo `.tscn`) y `discard_previous`
(bandera para indicar si es un botón de "volver"). Se usa como instancia
dentro de `menu_panel`, `configurator_panel` y `credits_panel`, sin que
esos paneles necesiten declarar su propio callback de navegación.

## 🎨 Identidad Visual
El proyecto usa un tema industrial (grises oscuros con acento naranja),
definido en un único recurso `Theme` de Godot
(`src/assets/ui/theme_industrial.tres`) y aplicado globalmente desde la
configuración del proyecto. Las transiciones entre pantallas usan un
`Tween` con curva de suavizado para una aparición más natural.

## ⚙️ Tecnologías Utilizadas
* **Engine:** Godot Engine 4.x (Renderizador: *Compatibility* para portabilidad web)
* **Lenguaje:** GDScript 2.0 (Tipado estricto)
* **Versionamiento:** Git / GitHub

## 🎨 Personalización del Proyecto
El nombre, la descripción y el tema visual del proyecto se configuraron
desde el panel interno de Godot Engine:

**Project > Project Settings > Application > Config** (nombre y descripción)
**Project > Project Settings > GUI** (tema visual global)

## 👨‍💻 Autor
* **Nombre:** Jorge Eliecer Montes Rodríguez
* **Código Estudiantil:** 12242614169
* **Programa:** Ingeniería de Software
