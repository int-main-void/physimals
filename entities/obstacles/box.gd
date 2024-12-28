class_name Box extends RigidBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	add_to_group("obstacles")

func hit(_other: Node2D) -> void:
	animation_player.play("explosion")
	
func die() -> void:
	queue_free()
