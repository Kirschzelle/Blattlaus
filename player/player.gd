extends CharacterBody2D

const SPEED = 50
const KNOCKBACKINTENSITYFACTOR = 1.0 #This sets the ratio at which knockbacks get longer per incresing intensity. Ex. 0.5 would be: if attack is twice as strong, your knockbacked with twice the speed, but only unable to move for 1.5 times the time.
const DASHLENGTH = 0.15
const DASHSPEEDFACTOR = 3
const STANDARDATTACKDISTANCE = 10

var constSpeedMultiplier = 1.0
var knockBackPercentage = 0.0
var knockBackIntensity = 1.0 #1.0 stands for 1 Second until you are able to completly move again.
var knockBackVelocity = Vector2(0,0)
var knockedBack = false
var dashTimer = 0
var dashSpeedMultiplier = 1.0
var dashLengthMultiplier = 1.0
var dashing = false
var attack = 10
var attackSpeed = 1
var attackCooldown = 0
var attackLength = 0.5
var attackShape
var collisionShape

func _init():
	create_attack_shape()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if attackCooldown > 0:
		attackCooldown -= delta
	
	if Input.is_action_pressed("ui_attack") && attackCooldown <= 0:
		attackShape.monitoring = true
		update_attack_shape()
	elif attackCooldown < attackLength:
		attackShape.monitoring = false
		
func create_attack_shape():
	attackShape = Area2D.new()
	add_child(attackShape)
		
	collisionShape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(15, 15)
	collisionShape.shape = shape
		
	attackShape.add_child(collisionShape)
	attackShape.position = velocity.normalized()
		
	attackShape.collision_layer = 0
	attackShape.collision_mask = CollisionLayers.COLLISION_LAYER_ENEMY
	
	attackShape.monitorable = false
	attackShape.monitoring = false

func update_attack_shape():
	var attackDirection = Vector2(get_global_mouse_position().x - global_position.x, get_global_mouse_position().y - global_position.y).normalized()
	attackShape.position = attackDirection * STANDARDATTACKDISTANCE
	attackShape.rotation = attackDirection.angle()
	attackCooldown = attackSpeed
	
func init_new_enemy(body):
	attackShape.body_entered.connect(_enemy_detected, body.get_instance_id())
	
func _enemy_detected(body):
	body.init_newKnockBack(body.global_position - global_position, attack)
	
func _physics_process(delta):
	calculate_movement(delta)

func calculate_movement(delta):
	calculate_knockBack(delta)
	if attackCooldown <= attackLength:
		if dashing:
			calculate_dash(delta)
		else:
			calculate_input(delta)
			listener_dash()
	move_and_slide()
	
func calculate_input(delta):
	var movementInput = Input.get_vector("ui_left","ui_right", "ui_up", "ui_down") * SPEED * constSpeedMultiplier
	velocity = velocity * knockBackPercentage + movementInput * (1-knockBackPercentage)
	
func init_newKnockBack(inputVector, intensity):
	if inputVector != Vector2(0,0):
		var tempVector = Vector2(0,0)
		if knockBackPercentage * knockBackIntensity <= 1.0 * intensity:
			knockedBack = true
			knockBackIntensity = intensity * KNOCKBACKINTENSITYFACTOR
			knockBackPercentage = 1.0
		knockBackVelocity = knockBackVelocity + tempVector.direction_to(inputVector) * SPEED * intensity
	
func calculate_knockBack(delta):
	if knockedBack:
		if knockBackVelocity != Vector2(0,0):
			velocity = velocity + knockBackVelocity
			knockBackVelocity = Vector2(0,0)
		knockBackPercentage -= (1/knockBackIntensity)*delta
		if knockBackPercentage <= 0:
			knockBackPercentage = 0
			knockedBack = false
			
func listener_dash():
	if Input.get_action_strength("ui_dash") > 0 && velocity != Vector2(0,0) && dashing == false:
		dashing = true
		dashTimer = DASHLENGTH * dashLengthMultiplier
		velocity *= DASHSPEEDFACTOR * dashSpeedMultiplier
			
func calculate_dash(delta):
	dashTimer -= delta
	if dashTimer <= 0:
		dashTimer = 0
		dashing = false
		velocity /= DASHSPEEDFACTOR * dashSpeedMultiplier
