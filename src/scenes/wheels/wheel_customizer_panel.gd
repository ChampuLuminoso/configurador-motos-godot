# res://src/scenes/wheels/wheel_customizer_panel.gd
# Laboratorio 9 — Interfaz Dinámica y Representación de Datos mediante
# recursos, adaptada al proyecto de motos.
#
# Esta pantalla NO reemplaza al configurador existente (color +
# accesorios de los Laboratorios 1-8): es una nueva pantalla aparte,
# igual que buy_panel_interactive conserva buy_panel en la guía
# original. Aquí la lista de rines se genera automáticamente a partir
# de GlobalManager.rims (un catálogo de Resource), en vez de botones
# fijos escritos a mano.
extends Control

@onready var lbl_total: Label = $HBoxMain/RimScroll/VBoxContainer/LblTotal
@onready var rim_list: Container = $HBoxMain/RimScroll/VBoxContainer/RimList
@onready var wheel_composition: Control = $HBoxMain/PanelWheels/WheelComposition

func _ready() -> void:
	for rim: RimData in GlobalManager.rims:
		var button: Button = Button.new()
		button.text = "%s ($%d)" % [rim.display_name, rim.price]
		button.pressed.connect(_on_rim_button_pressed.bind(rim))
		rim_list.add_child(button)

	EventBus.rim_total_changed.connect(_on_total_changed)
	_on_total_changed(GlobalManager.moto_rines_total)

func _on_rim_button_pressed(rim: RimData) -> void:
	wheel_composition._on_rim_selected(rim)

func _on_total_changed(new_total: int) -> void:
	lbl_total.text = "Total rines: $%d" % new_total
