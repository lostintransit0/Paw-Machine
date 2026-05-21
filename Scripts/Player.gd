extends CharacterBody2D
class_name Player

@export var uiManager : UImanager

@export_group("Movement")

@export var speed : float = 300.0
@export var acceleration : float = 10.0
@export var deceleration : float = 14.0
@export var drops : int = 5

@export_group("Claw")

@export var Cat : RigidBody2D
@export var CatHitbox : CollisionShape2D
@export var minimumRopeLength : float = 50.0
@export var ropeDropSpeed : float = 75.0
@export var rotationSpeed : float = 16.0

@export_group("Grab")

@export var grabPullStrength : float = 30.0

@onready var retractDelay: Timer = $RetractDelay
@onready var string: Line2D = $String

@export_group("Panic")

@export var panicForce : float = 2500.0
@onready var panicArea: Area2D = $"../Cat/PanicArea"

var ropeLength : float
var grabTarget : GrabbableItem
var bodiesAffected : int

enum STATE {
	IDLE,
	GRABBING,
	RETRACTING,
	PANICKING
}

var currentState: STATE = STATE.IDLE

var Points = {
	GrabbableItem.RARITY.COMMON: 100,
	GrabbableItem.RARITY.UNCOMMON: 200,
	GrabbableItem.RARITY.RARE: 500,
	GrabbableItem.RARITY.LEGENDARY: 1500
}

func _ready() -> void:
	Cat.contact_monitor = true
	Cat.max_contacts_reported = 10
	Cat.lock_rotation = true
	Cat.body_entered.connect(_on_collide)
	ropeLength = minimumRopeLength
	retractDelay.timeout.connect(_on_timeout)
	uiManager.updateBoard(drops)
	
func _physics_process(delta):
	match currentState:
		STATE.IDLE:
			Idle(delta)
		STATE.GRABBING:
			Grabbing(delta)
		STATE.RETRACTING:
			Retracting(delta)
		STATE.PANICKING:
			Panicking(delta)
func Grabbing(delta):
	velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
	ropeLength += ropeDropSpeed * delta
	
	basicPhysics()
	var target_rotation = position.direction_to(Cat.position).angle() - PI / 2
	Cat.rotation = lerp_angle(Cat.rotation, target_rotation, rotationSpeed * delta)

func Retracting(delta):
	CatHitbox.disabled = false
	velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
	if retractDelay.is_stopped():
		ropeLength -= ropeDropSpeed * delta
	else:
		ropeLength += ropeDropSpeed * delta
		
	if ropeLength < minimumRopeLength:
		ropeLength = minimumRopeLength
		currentState = STATE.IDLE
		grabTarget.collider.disabled = true
		grabTarget.z_index = -1000
		grabTarget.modulate = Color.WEB_GRAY
		grabTarget.canDelete = true
		uiManager.addScore(Points[grabTarget.currentRarity])
		uiManager.updateBoard(drops)
	basicPhysics()
	
	var target_rotation = Cat.global_position.direction_to(grabTarget.global_position).angle() - PI/2
	Cat.rotation = lerp_angle(Cat.rotation, target_rotation, rotationSpeed * delta)
	
	if grabTarget:
		
		var offset = grabTarget.global_position - Cat.global_position
		var distance = offset.length()

		var size = grabTarget.texture.get_size()
		var max_distance = max(size.x, size.y) + 10

		if distance > max_distance:
			var direction = offset.normalized()

			grabTarget.global_position = Cat.global_position + direction * max_distance

			var outward_speed = grabTarget.linear_velocity.dot(direction)

			if outward_speed > 0:
				grabTarget.linear_velocity -= direction * outward_speed

		var pull_direction = grabTarget.global_position.direction_to(Cat.global_position)

		grabTarget.linear_velocity += pull_direction * 30.0 * delta
func Idle(delta):
	grabTarget = null
	
	var input_direction = Input.get_axis("left", "right")
	var target_velocity = input_direction * speed

	if input_direction != 0:
		velocity.x = lerp(velocity.x, target_velocity, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, deceleration * delta)

	move_and_slide()
	
	basicPhysics()
	var target_rotation = position.direction_to(Cat.position).angle() - PI / 2
	Cat.rotation = lerp_angle(Cat.rotation, target_rotation, rotationSpeed * delta)

func Panicking(delta):
	ropeLength += ropeDropSpeed * delta
	CatHitbox.disabled = true
	
	velocity.x = lerp(velocity.x, 0.0, deceleration * delta)

	basicPhysics()

	var target_rotation = position.direction_to(Cat.position).angle() - PI / 2
	Cat.rotation = lerp_angle(Cat.rotation, target_rotation, rotationSpeed * delta)

	apply_panic_force(delta)

func apply_panic_force(_delta):
	var bodies = panicArea.get_overlapping_bodies()
	
	for body in bodies:
		if body == self or body == Cat:
			continue
		
		bodiesAffected += 1
		
		if body is RigidBody2D:
			var rigid = body as RigidBody2D

			var horizontal = -1 if randf() < 0.5 else 1

			var direction = Vector2(horizontal, -1).normalized()

			rigid.apply_central_force(direction * panicForce)
func basicPhysics():
	constrain_cat()
	
	updateLine()

func updateLine():
	string.set_point_position(0, Vector2.ZERO)
	string.set_point_position(1, to_local(Cat.global_position))

func constrain_cat():

	var offset = Cat.global_position - global_position
	var distance = offset.length()

	if distance > ropeLength:

		var direction = offset.normalized()

		Cat.global_position = global_position + direction * ropeLength

		var outward_speed = Cat.linear_velocity.dot(direction)

		if outward_speed > 0:
			Cat.linear_velocity -= direction * outward_speed

func _on_timeout():
	ropeLength = Cat.position.distance_to(position)
	
func _on_collide(body: Node):
	if body is not GrabbableItem or not currentState == STATE.GRABBING:
		return
	
	grabTarget = body as GrabbableItem
	currentState = STATE.RETRACTING
	retractDelay.start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ClawDown") and not drops == 0:
		currentState = STATE.GRABBING
		drops -= 1
		uiManager.updateBoard(drops)
