# res://src/scenes/configurator/configurator_panel.gd
# ---------------------------------------------------------------------------
# Actualizado con mecánicas de interacción básicas (mismo patrón aplicado
# en el proyecto del curso): entrada por teclado que reutiliza los
# mismos callbacks de siempre, y una zona de interacción que resalta
# qué opción está bajo el mouse. Nada del flujo reactivo con EventBus /
# GlobalManager cambia.
# ---------------------------------------------------------------------------
extends Control

# La imagen de la moto es UNA sola (ya en escala de grises, con el
# contorno en negro) y se "pinta" con un tinte multiplicativo distinto
# según el color elegido. Así no necesitas una foto por cada color.
const COLOR_TINTS: Dictionary = {
	"Negro": Color("1a1a1a"),
	"Rojo": Color("c0392b"),
	"Azul": Color("2980b9"),
}

@onready var btn_color_negro: Button = $HBoxMain/SidebarScroll/PanelSidebar/GridColores/BtnColorNegro
@onready var btn_color_rojo: Button = $HBoxMain/SidebarScroll/PanelSidebar/GridColores/BtnColorRojo
@onready var btn_color_azul: Button = $HBoxMain/SidebarScroll/PanelSidebar/GridColores/BtnColorAzul

@onready var btn_parabrisas: Button = $HBoxMain/SidebarScroll/PanelSidebar/GridAccesorios/BtnParabrisas
@onready var btn_alforjas: Button = $HBoxMain/SidebarScroll/PanelSidebar/GridAccesorios/BtnAlforjas
@onready var btn_escape: Button = $HBoxMain/SidebarScroll/PanelSidebar/GridAccesorios/BtnEscape

# Laboratorio 9 — lista de rines generada automáticamente desde
# GlobalManager.rims (catálogo de Resource), ningún botón escrito a mano.
@onready var grid_rines: Container = $HBoxMain/SidebarScroll/PanelSidebar/GridRines
@onready var wheel_composition: WheelComposition = $HBoxMain/PanelVista/WheelComposition

@onready var vista_moto: TextureRect = $HBoxMain/PanelVista/VistaMoto
@onready var lbl_placeholder: Label = $HBoxMain/PanelVista/VistaMoto/LblPlaceholder
@onready var btn_voltear: Button = $HBoxMain/PanelVista/BtnVoltear
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

	btn_voltear.pressed.connect(_on_btn_voltear_pressed)

	# Laboratorio 9 — un botón por cada rin del catálogo, generado
	# automáticamente. Agregar un rin nuevo a rim_database.tres no
	# requiere tocar esta pantalla.
	for rim: RimData in GlobalManager.rims:
		var boton_rin: Button = Button.new()
		boton_rin.text = "%s (%s)" % [rim.display_name, _formatear_precio(rim.price)]
		boton_rin.pressed.connect(_on_rim_button_pressed.bind(rim))
		grid_rines.add_child(boton_rin)

	EventBus.rim_total_changed.connect(_on_rim_total_changed)

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
		KEY_7:
			_on_btn_voltear_pressed()

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
	_mostrar_imagen_color(GlobalManager.color_actual)

	if GlobalManager.accesorios_activos.has("Parabrisas"):
		btn_parabrisas.button_pressed = true
	if GlobalManager.accesorios_activos.has("Alforjas"):
		btn_alforjas.button_pressed = true
	if GlobalManager.accesorios_activos.has("Escape Deportivo"):
		btn_escape.button_pressed = true

	# Laboratorio 9 — si ya habías elegido rines, se vuelven a mostrar.
	for wheel: String in ["front", "rear"]:
		var rim_id: String = GlobalManager.moto_rines.get(wheel, "")
		if rim_id.is_empty():
			continue
		for rim: RimData in GlobalManager.rims:
			if rim.id == rim_id:
				wheel_composition.aplicar_rim_guardado(rim, wheel)
				break

	_actualizar_total_combinado()

func _on_color_button_pressed(nombre_color: String) -> void:
	EventBus.color_selected.emit(nombre_color)

func _on_accessory_button_toggled(activado: bool, nombre_accesorio: String) -> void:
	EventBus.accessory_toggled.emit(nombre_accesorio, activado)

func _on_color_changed(nombre_color: String) -> void:
	_mostrar_imagen_color(nombre_color)

## Aplica el tinte correspondiente sobre la imagen base de la moto.
func _mostrar_imagen_color(nombre_color: String) -> void:
	if not COLOR_TINTS.has(nombre_color):
		return
	vista_moto.modulate = COLOR_TINTS[nombre_color]

## "Espejo" horizontal: no es un giro 3D real, pero deja ver la moto
## mirando hacia el otro lado con una sola imagen.
func _on_btn_voltear_pressed() -> void:
	vista_moto.flip_h = not vista_moto.flip_h

func _on_total_changed(_nuevo_total: int) -> void:
	_actualizar_total_combinado()

func _on_rim_total_changed(_nuevo_total: int) -> void:
	_actualizar_total_combinado()

## Laboratorio 9 — el botón de un rin no sabe a qué rueda se aplica;
## eso lo decide WheelComposition según cuál esté activa en ese momento.
func _on_rim_button_pressed(rim: RimData) -> void:
	wheel_composition._on_rim_selected(rim)

## El total mostrado ahora suma accesorios + rines, en vez de ser cada
## uno un número aparte.
func _actualizar_total_combinado() -> void:
	lbl_total.text = "Total: $%d" % (GlobalManager.precio_total + GlobalManager.moto_rines_total)

## Formatea un entero con puntos de miles, estilo "$180.000", igual que
## el texto escrito a mano en los botones de accesorios.
func _formatear_precio(valor: int) -> String:
	var texto: String = str(valor)
	var resultado: String = ""
	var contador: int = 0
	for i in range(texto.length() - 1, -1, -1):
		resultado = texto[i] + resultado
		contador += 1
		if contador % 3 == 0 and i != 0:
			resultado = "." + resultado
	return "$" + resultado

func _on_zona_mouse_entered(nombre_zona: String) -> void:
	lbl_zona_activa.text = "Zona activa: %s" % nombre_zona

func _on_zona_mouse_exited() -> void:
	lbl_zona_activa.text = "Zona activa: ninguna"
