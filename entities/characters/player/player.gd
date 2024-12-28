extends RigidBody2D

signal launched

@export var speed = 50.0


@onready var drag_zone: Area2D = $DragZone
@onready var hurtbox: Area2D = $Hurtbox

var vel: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var mouse_start: Vector2 = Vector2.ZERO
var move_loc: Vector2 = Vector2.ZERO
var last_move_loc: Vector2 = Vector2.ZERO

func _ready() -> void:
	hurtbox.area_entered.connect(_on_hurtbox_entered)
	
	var pm: PhysicsMaterial = PhysicsMaterial.new()
	pm.bounce = 0.4
	pm.friction = 0.5
	
	set_physics_material_override(pm)
	
	can_sleep = false
	lock_rotation = true
	#angular_damp = 15

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if (! is_dragging) and (vel.length_squared() > 0.0):
		print("integrating force: ", vel)
		state.apply_impulse(vel)
		vel = Vector2.ZERO
		launched.emit()
	elif move_loc != Vector2.ZERO:
		#print("move it! ", (move_loc - last_move_loc))
		position += (move_loc - last_move_loc)
		last_move_loc = move_loc
		move_loc = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and (
			event.button_index == MOUSE_BUTTON_LEFT 
			and is_dragging 
			and not event.pressed
		)
	):
			is_dragging = false
			var dir = (mouse_start - event.position).normalized()
			var amt = (mouse_start - event.position).length() * speed
			vel = dir * amt
			print("time to fly! pos: %s mouse_start: %s  mouse: %s  dir: %s  amt: %s  vel: %s" % 
			[global_position, mouse_start, event.position, dir, amt, vel])

	elif event is InputEventMouseMotion and is_dragging:
		move_loc = event.position

# ------------------------------------------------------------
# ------------------------------------------------------------
# ------------------------------------------------------------
# ------------------------------------------------------------



func _on_drag_zone_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (
		event is InputEventMouseButton 
		and event.button_index == MOUSE_BUTTON_LEFT 
		and event.pressed
	):
		if is_dragging:
			return

		if ! vel.is_zero_approx():
			return

		print("left click!")
		is_dragging = true
		mouse_start = event.position
		move_loc = event.position
		last_move_loc = event.position

func _on_hurtbox_entered(area: Area2D) -> void:
	var other = area.get_parent()
	if other.is_in_group("obstacles"):
		print("ouch! ", other)
		if other.has_method("hit"):
			other.hit(self)
		
