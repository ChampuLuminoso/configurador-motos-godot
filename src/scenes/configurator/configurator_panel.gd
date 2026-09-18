# res://src/scenes/configurator/configurator_panel.gd
# ---------------------------------------------------------------------------
# Actualizado con mecánicas de interacción básicas (mismo patrón aplicado
# en el proyecto del curso): entrada por teclado que reutiliza los
# mismos callbacks de siempre, y una zona de interacción que resalta
# qué opción está bajo el mouse. Nada del flujo reactivo con EventBus /
# GlobalManager cambia.
# ---------------------------------------------------------------------------
extends Control

# Reemplaza esto por rutas de imagen cuando tengas fotos reales de la moto.
const COLORES: Dictionary = {
	"Negro": Color("1a1a1a"),
	"Rojo": Color("c0392b"),
	"Azul": Color("2980b9"),
}

@onready var btn_color_negro: Button = $HBoxMain/PanelSidebar/GridColores/BtnColorNegro
@onready var btn_color_rojo: Button = $HBoxMain/PanelSidebar/GridColores/BtnColorRojo
@onready var btn_color_azul: Button = $HBoxMain/PanelSidebar/GridColores/BtnColorAzul

@onready var btn_parabrisas: Button = $HBoxMain/PanelSidebar/GridAccesorios/BtnParabrisas
@onready var btn_alforjas: Button = $HBoxMain/PanelSidebar/GridAccesorios/BtnAlforjas
@onready var btn_escape: Button = $HBoxMain/PanelSidebar/GridAccesorios/BtnEscape

@onready var vista_moto: ColorRect = $HBoxMain/PanelVista/VistaMoto
@onready var lbl_placeholder: Label = $HBoxMain/PanelVista/VistaMoto/LblPlaceholder
@onready var lbl_total: Label = $BarraInferior/LblTotal
@onready var lbl_zona_activa: Label = $LblZonaActiva

func _ready() -> void:
	# Solo avisas la intención, no decides qué pasa después.
	btn_color_negro.pressed.connect(_on_color_button_pressed.bind("Negro"))
	btn_color_rojo.pressed.connect(_on_color_button_pressed.bind("Rojo"))
	btn_color_azul.pressed.connect(_on_color_button_pressed.bind("Azul"))

	btn_parabrisas.toggled.connect(_on_accessory_button_toggled.bind("Parabrisas"))
	btn_alforjas.toggled.connect(_on_accessory_button_toggled.bind("Alforjas"))
	btn_escape.toggled.connect(_on_accessory_button_toggled.bind("Escape Deportivo"))

	# --- Zona de interacción: resalta qué opción está bajo el mouse ---
	for boton_zona: Dictionary in [
		{"nodo": btn_color_negro, "nombre": "Color Negro"},
		{"nodo": btn_color_rojo, "nombre": "Color Rojo"},
		{"nodo": btn_color_azul, "nombre": "Color Azul"},
		{"nodo": btn_parabrisas, "nombre": "Parabrisas"},
		{"nodo": btn_alforjas, "nombre": "Alforjas"},
		{"nodo": btn_escape, "nombre": "Escape Deportivo"},
	]:
		var boton: Button = boton_zona["nodo"]
		boton.mouse_entered.connect(_on_zona_mouse_entered.bind(boton_zona["nombre"]))
		boton.mouse_exited.connect(_on_zona_mouse_exited)

	# Escuchas lo que GlobalManager decide, sin llamarlo directamente.
	EventBus.color_changed.connect(_on_color_changed)
	EventBus.total_changed.connect(_on_total_changed)

	_restaurar_estado_actual()
	_reproducir_fade_in()

func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	# El teclado reutiliza los mismos callbacks que los botones: nada de
	# lógica de selección duplicada.
	match event.keycode:
		KEY_1:
			_on_color_button_pressed("Negro")
		KEY_2:
			_on_color_button_pressed("Rojo")
		KEY_3:
			_on_color_button_pressed("Azul")
		KEY_4:
			_alternar_accesorio_por_teclado(btn_parabrisas, "Parabrisas")
		KEY_5:
			_alternar_accesorio_por_teclado(btn_alforjas, "Alforjas")
		KEY_6:
			_alternar_accesorio_por_teclado(btn_escape, "Escape Deportivo")

func _alternar_accesorio_por_teclado(boton: Button, nombre_accesorio: String) -> void:
	boton.button_pressed = not boton.button_pressed
	_on_accessory_button_toggled(boton.button_pressed, nombre_accesorio)

func _reproducir_fade_in() -> void:
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.25)

func _restaurar_estado_actual() -> void:
	# Si vuelves a esta pantalla, recuperas lo que ya tenías elegido.
	if GlobalManager.color_actual in COLORES:
		vista_moto.color = COLORES[GlobalManager.color_actual]
		lbl_placeholder.visible = false

	if GlobalManager.accesorios_activos.has("Parabrisas"):
		btn_parabrisas.button_pressed = true
	if GlobalManager.accesorios_activos.has("Alforjas"):
		btn_alforjas.button_pressed = true
	if GlobalManager.accesorios_activos.has("Escape Deportivo"):
		btn_escape.button_pressed = true

	lbl_total.text = "Total accesorios: $%d" % GlobalManager.precio_total

func _on_color_button_pressed(nombre_color: String) -> void:
	EventBus.color_selected.emit(nombre_color)

func _on_accessory_button_toggled(activado: bool, nombre_accesorio: String) -> void:
	EventBus.accessory_toggled.emit(nombre_accesorio, activado)

func _on_color_changed(nombre_color: String) -> void:
	if COLORES.has(nombre_color):
		vista_moto.color = COLORES[nombre_color]
		lbl_placeholder.visible = false

func _on_total_changed(nuevo_total: int) -> void:
	lbl_total.text = "Total accesorios: $%d" % nuevo_total

func _on_zona_mouse_entered(nombre_zona: String) -> void:
	lbl_zona_activa.text = "Zona activa: %s" % nombre_zona

func _on_zona_mouse_exited() -> void:
	lbl_zona_activa.text = "Zona activa: ninguna"
