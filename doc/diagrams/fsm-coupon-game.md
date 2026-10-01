# Diagrama de Estados — CouponGame "Taller de Repuestos" (Laboratorio 6)

Componente: `src/scenes/gamification/coupon_game.gd`

```mermaid
stateDiagram-v2
    [*] --> PLAYING: _ready()

    PLAYING --> WON: collected_items >= target_items
    PLAYING --> LOST: current_spawned_items > max_spawned_items

    WON --> [*]
    LOST --> [*]

    state PLAYING {
        [*] --> MoviendoJugador
        MoviendoJugador --> Recolectando: AreaRecolect.body_entered
        Recolectando --> MoviendoJugador
    }

    state WON {
        [*] --> EmitiendoCupon
        EmitiendoCupon --> AnimandoPanel
    }

    state LOST {
        [*] --> AnimandoPanel
    }
```

## Tabla de transiciones

| Desde | Hacia | Evento / condición | ¿Permitida? |
|---|---|---|---|
| `PLAYING` | `WON` | `collected_items >= target_items` | ✅ |
| `PLAYING` | `LOST` | `current_spawned_items > max_spawned_items` | ✅ |
| `WON` | cualquiera | — | ❌ (estado terminal) |
| `LOST` | cualquiera | — | ❌ (estado terminal) |

`change_state()` es la única función que modifica `current_state`.
