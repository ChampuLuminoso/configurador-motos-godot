# res://src/scenes/configurator/configurator_panel.gd
extends Control

const MENU_SCENE_PATH: String = "res://src/scenes/menu/menu_panel.tscn"

# Colores disponibles (nombre -> Color). Cuando tengas fotos reales,
# reemplaza esto por rutas de textura, ej: {"Negro": "res://.../negro.png"}
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
@onready var btn_volver: Button = $BarraInferior/BtnVolver

func _ready() -> void:
	# --- Conexión local con callback único por grupo (mismo patrón del Lab 1) ---
	btn_color_negro.pressed.connect(_on_color_selected.bind("Negro"))
	btn_color_rojo.pressed.connect(_on_color_selected.bind("Rojo"))
	btn_color_azul.pressed.connect(_on_color_selected.bind("Azul"))

	btn_parabrisas.toggled.connect(_on_accesorio_toggled.bind("Parabrisas", 150000))
	btn_alforjas.toggled.connect(_on_accesorio_toggled.bind("Alforjas", 300000))
	btn_escape.toggled.connect(_on_accesorio_toggled.bind("Escape Deportivo", 450000))

	btn_volver.pressed.connect(_on_btn_volver_pressed)

	# --- Restaurar el estado guardado en ConfigState (persistencia entre escenas) ---
	_restaurar_estado_guardado()
	_actualizar_total()
	_reproducir_fade_in()

func _reproducir_fade_in() -> void:
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)

func _restaurar_estado_guardado() -> void:
	if ConfigState.color_seleccionado in COLORES:
		vista_moto.color = COLORES[ConfigState.color_seleccionado]
		lbl_placeholder.visible = false

	if ConfigState.accesorios_seleccionados.has("Parabrisas"):
		btn_parabrisas.button_pressed = true
	if ConfigState.accesorios_seleccionados.has("Alforjas"):
		btn_alforjas.button_pressed = true
	if ConfigState.accesorios_seleccionados.has("Escape Deportivo"):
		btn_escape.button_pressed = true

func _on_color_selected(nombre_color: String) -> void:
	ConfigState.establecer_color(nombre_color)

	# TODO (siguiente paso): cuando tengas fotos reales de la moto,
	# reemplaza esta línea por vista_moto.texture = load(ruta_de_la_foto)
	# usando un TextureRect en lugar de un ColorRect.
	vista_moto.color = COLORES[nombre_color]
	lbl_placeholder.visible = false

	EventBus.parameter_changed.emit("color", nombre_color)

func _on_accesorio_toggled(activado: bool, nombre: String, precio: int) -> void:
	if activado:
		ConfigState.agregar_accesorio(nombre, precio)
	else:
		ConfigState.quitar_accesorio(nombre, precio)

	EventBus.parameter_changed.emit(nombre, activado)
	_actualizar_total()

func _actualizar_total() -> void:
	lbl_total.text = "Total accesorios: $%d" % ConfigState.precio_total

func _on_btn_volver_pressed() -> void:
	EventBus.navigation_requested.emit(MENU_SCENE_PATH)
