# res://src/scenes/gamification/falling_part.gd
# Un repuesto que cae. Si el jugador lo recolecta se destruye desde
# player.gd. Si toca el suelo sin ser recolectado, se destruye solo.
extends RigidBody2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("floor"):
		queue_free()
