# res://src/scenes/configurator/configurator_panel.gd
# Aquí no calculas ningún precio: solo avisas por el EventBus qué elegiste
# (color o accesorio) y esperas a que GlobalManager te devuelva el
# resultado para actualizar lo que ves en pantalla.
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

func _ready() -> void:
	# Solo avisas la intención, no decides qué pasa después.
	btn_color_negro.pressed.connect(_on_color_button_pressed.bind("Negro"))
	btn_color_rojo.pressed.connect(_on_color_button_pressed.bind("Rojo"))
	btn_color_azul.pressed.connect(_on_color_button_pressed.bind("Azul"))

	btn_parabrisas.toggled.connect(_on_accessory_button_toggled.bind("Parabrisas"))
	btn_alforjas.toggled.connect(_on_accessory_button_toggled.bind("Alforjas"))
	btn_escape.toggled.connect(_on_accessory_button_toggled.bind("Escape Deportivo"))

	# Escuchas lo que GlobalManager decide, sin llamarlo directamente.
	EventBus.color_changed.connect(_on_color_changed)
	EventBus.total_changed.connect(_on_total_changed)

	_restaurar_estado_actual()
	_reproducir_fade_in()

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
