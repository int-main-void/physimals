extends Node2D

@onready var player: RigidBody2D = $Player
@onready var slingshot: Node2D = $Slingshot

var joint: Joint2D

func _ready() -> void:
	player.launched.connect(_on_player_launched)
	#attach_player_to_sling()

func attach_player_to_sling() -> void:
	joint = DampedSpringJoint2D.new()
	joint.length = 50.0
	joint.stiffness = 20.0
	joint.rest_length = 10.0
	joint.damping = 1.0 
	joint.node_a = "./Player"
	joint.node_b = "./Slingshot"

func _on_player_launched() -> void:
	if joint:
		joint.queue_free()
		joint = null
