# res://src/scenes/gamification/player.gd
# El jugador (mecánico) se mueve horizontalmente con move_left/move_right
# (mapeados en el Input Map). Detecta recolección a través de
# AreaRecolect y avisa con una señal propia, sin conocer al controlador
# del minijuego.
extends CharacterBody2D

signal collected_food

@export var speed: float = 300.0

func _ready() -> void:
	$AreaRecolect.body_entered.connect(_on_collect_area_body_entered)

func _physics_process(_delta: float) -> void:
	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
	move_and_slide()

func _on_collect_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("collectable"):
		collected_food.emit()
		body.queue_free()
