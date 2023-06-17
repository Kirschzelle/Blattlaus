extends CharacterBody2D

const SPEED = 50
const KNOCKBACKINTENSITYFACTOR = 1.0 #This sets the ratio at which knockbacks get longer per incresing intensity. Ex. 0.5 would be: if attack is twice as strong, your knockbacked with twice the speed, but only unable to move for 1.5 times the time.
const DASHLENGTH = 0.25
const DASHSPEEDFACTOR = 3.5
const DASH_COOLDOWN = 4
const STANDARDATTACKDISTANCE = 8
const ANIMATION_RUNNING_LOOP_TIME = 0.5
const ANIMATION_IDLE_LOOP_TIME = 1.0
const ANIMATION_DASHING_TIME = 0.1

var constSpeedMultiplier = 1.0
var knockBackPercentage = 0.0
var knockBackIntensity = 1.0 #1.0 stands for 1 Second until you are able to completly move again.
var knockBackVelocity = Vector2(0,0)
var knockedBack = false
var dashTimer = 0
var dashSpeedMultiplier = 1.0
var dashLengthMultiplier = 1.0
var dashing = false
var attack = 1
var attackSpeed = 1
var attackCooldown = 0
var attackLength = 0.5
var attackShape
var collisionShape
var animationState = "idle"
var animationTimer = 0.0
var animationOldAngle = Vector2(1,0)
var dashcooldown = 0

func _init():
	create_attack_shape()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dashcooldown > 0:
		dashcooldown -= delta
	
	if attackCooldown > 0:
		attackCooldown -= delta
	
	if Input.is_action_pressed("ui_attack") && attackCooldown <= 0:
		attackShape.monitoring = true
		animationState = "attacking"
		update_attack_shape()
	elif attackCooldown < attackLength:
		attackShape.monitoring = false
	else:
		animationState = "attacking"
	animate(delta)
		
func create_attack_shape():
	attackShape = Area2D.new()
	add_child(attackShape)
	collisionShape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(15, 4)
	collisionShape.shape = shape
	attackShape.add_child(collisionShape)
	attackShape.position = velocity.normalized()
	attackShape.collision_layer = 0
	attackShape.collision_mask = CollisionLayers.COLLISION_LAYER_ENEMY + CollisionLayers.COLLISION_LAYER_PROJECTILES
	attackShape.monitorable = false
	attackShape.monitoring = false

func update_attack_shape():
	var attackDirection = Vector2(get_global_mouse_position().x - global_position.x, get_global_mouse_position().y - global_position.y).normalized()
	attackShape.position = attackDirection * STANDARDATTACKDISTANCE + Vector2(0,2)
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
	elif !knockedBack:
		velocity *= 0.5
	move_and_slide()
	
func calculate_input(_delta):
	var movementInput = Input.get_vector("ui_left","ui_right", "ui_up", "ui_down") * SPEED * constSpeedMultiplier
	velocity = velocity * knockBackPercentage + movementInput * (1-knockBackPercentage)
	if knockBackPercentage > 0.85 && velocity != Vector2(0,0):
		animationState = "knockedBacked"
	elif movementInput != Vector2(0,0):
			animationState = "running"
	else:
		animationState = "idle"
	
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
	if Input.get_action_strength("ui_dash") > 0 && velocity != Vector2(0,0) && dashing == false && dashcooldown <= 0:
		dashing = true
		dashTimer = DASHLENGTH * dashLengthMultiplier
		velocity *= DASHSPEEDFACTOR * dashSpeedMultiplier
			
func calculate_dash(delta):
	dashTimer -= delta
	if dashTimer <= 0:
		dashTimer = 0
		dashing = false
		velocity /= DASHSPEEDFACTOR * dashSpeedMultiplier
		dashcooldown = DASH_COOLDOWN
	animationState = "dashing"

func animate(delta):
	if animationState == "idle":
		weapon_position_idle(true)
		if animationOldAngle.angle() < 3* PI/4 && animationOldAngle.angle() >= -PI/4-0.0000001:
			$hands.visible = true
			if animationTimer <= 0:
				animationTimer = ANIMATION_IDLE_LOOP_TIME
			elif animationTimer <= ANIMATION_IDLE_LOOP_TIME/2:
				$Sprite2D.frame = 1
				$hands.frame = 21
			elif animationTimer <= ANIMATION_IDLE_LOOP_TIME:
				$Sprite2D.frame = 0
				$hands.frame = 10
			elif animationTimer > ANIMATION_IDLE_LOOP_TIME:
				animationTimer = ANIMATION_IDLE_LOOP_TIME
		elif animationOldAngle.angle() <= PI/4 && animationOldAngle.angle() >= -3*PI/4:
			$hands.visible = false
			weapon_position_idle(false)
			if animationTimer <= 0:
				animationTimer = ANIMATION_IDLE_LOOP_TIME
			elif animationTimer <= ANIMATION_IDLE_LOOP_TIME/2:
				$Sprite2D.frame = 22
			elif animationTimer <= ANIMATION_IDLE_LOOP_TIME:
				$Sprite2D.frame = 23
			elif animationTimer > ANIMATION_IDLE_LOOP_TIME:
				animationTimer = ANIMATION_IDLE_LOOP_TIME
		else:
			$hands.visible = true
			if animationTimer <= 0:
				animationTimer = ANIMATION_IDLE_LOOP_TIME
			elif animationTimer <= ANIMATION_IDLE_LOOP_TIME/2:
				$Sprite2D.frame = 12
				$hands.frame = 21
			elif animationTimer <= ANIMATION_IDLE_LOOP_TIME:
				$Sprite2D.frame = 11
				$hands.frame = 10
			elif animationTimer > ANIMATION_IDLE_LOOP_TIME:
				animationTimer = ANIMATION_IDLE_LOOP_TIME
	elif animationState == "running":
		$hands.visible = true
		$hands.frame = 10
		weapon_position_idle(true)
		if velocity.angle() <= PI/4 && velocity.angle() >= -PI/4-0.0000001:
			if animationTimer <= 0:
				animationTimer = ANIMATION_RUNNING_LOOP_TIME
			elif animationTimer <= ANIMATION_RUNNING_LOOP_TIME/4:
				$Sprite2D.frame = 5
			elif animationTimer <= ANIMATION_RUNNING_LOOP_TIME/2:
				$Sprite2D.frame = 4
			elif animationTimer <= 3*ANIMATION_RUNNING_LOOP_TIME/4:
				$Sprite2D.frame = 3
			elif animationTimer <= ANIMATION_RUNNING_LOOP_TIME:
				$Sprite2D.frame = 2
			elif animationTimer > ANIMATION_RUNNING_LOOP_TIME:
				animationTimer = ANIMATION_RUNNING_LOOP_TIME
		elif velocity.angle() <= 3*PI/4 && velocity.angle() > 0:
			if animationTimer <= 0:
				animationTimer = ANIMATION_RUNNING_LOOP_TIME
			elif animationTimer <= ANIMATION_RUNNING_LOOP_TIME/4:
				$Sprite2D.frame = 16
			elif animationTimer <= ANIMATION_RUNNING_LOOP_TIME/2:
				$Sprite2D.frame = 15
			elif animationTimer <= 3*ANIMATION_RUNNING_LOOP_TIME/4:
				$Sprite2D.frame = 14
			elif animationTimer <= ANIMATION_RUNNING_LOOP_TIME:
				$Sprite2D.frame = 13
			elif animationTimer > ANIMATION_RUNNING_LOOP_TIME:
				animationTimer = ANIMATION_RUNNING_LOOP_TIME
		elif velocity.angle() >= -3*PI/4 && velocity.angle() < 0:
			$hands.visible = false
			weapon_position_idle(false)
			if animationTimer <= 0:
				animationTimer = ANIMATION_RUNNING_LOOP_TIME
			elif animationTimer <= ANIMATION_RUNNING_LOOP_TIME/4:
				$Sprite2D.frame = 20
			elif animationTimer <= ANIMATION_RUNNING_LOOP_TIME/2:
				$Sprite2D.frame = 19
			elif animationTimer <= 3*ANIMATION_RUNNING_LOOP_TIME/4:
				$Sprite2D.frame = 18
			elif animationTimer <= ANIMATION_RUNNING_LOOP_TIME:
				$Sprite2D.frame = 17
			elif animationTimer > ANIMATION_RUNNING_LOOP_TIME:
				animationTimer = ANIMATION_RUNNING_LOOP_TIME
		else:
			if animationTimer <= 0:
				animationTimer = ANIMATION_RUNNING_LOOP_TIME
			elif animationTimer <= ANIMATION_RUNNING_LOOP_TIME/4:
				$Sprite2D.frame = 9
			elif animationTimer <= ANIMATION_RUNNING_LOOP_TIME/2:
				$Sprite2D.frame = 8
			elif animationTimer <= 3*ANIMATION_RUNNING_LOOP_TIME/4:
				$Sprite2D.frame = 7
			elif animationTimer <= ANIMATION_RUNNING_LOOP_TIME:
				$Sprite2D.frame = 6
			elif animationTimer > ANIMATION_RUNNING_LOOP_TIME:
				animationTimer = ANIMATION_RUNNING_LOOP_TIME
	elif animationState == "dashing" || animationState == "knockedBack":
		$hands.visible = true
		$hands.frame = 10
		weapon_position_idle(true)
		if velocity.angle() <= PI/4 && velocity.angle() >= -PI/4-0.0000001:
			if animationTimer <= 0:
				animationTimer = ANIMATION_DASHING_TIME
			elif animationTimer <= ANIMATION_DASHING_TIME/2:
				$Sprite2D.frame = 25
			elif animationTimer <= ANIMATION_DASHING_TIME:
				$Sprite2D.frame = 24
			elif animationTimer > ANIMATION_DASHING_TIME:
				animationTimer = ANIMATION_DASHING_TIME
		elif velocity.angle() <= 3*PI/4 && velocity.angle() > 0:
			if animationTimer <= 0:
				animationTimer = ANIMATION_DASHING_TIME
			elif animationTimer <= ANIMATION_DASHING_TIME/2:
				$Sprite2D.frame = 29
			elif animationTimer <= ANIMATION_DASHING_TIME:
				$Sprite2D.frame = 28
			elif animationTimer > ANIMATION_DASHING_TIME:
				animationTimer = ANIMATION_DASHING_TIME
		elif velocity.angle() >= -3*PI/4 && velocity.angle() < 0:
			$hands.visible = false
			weapon_position_idle(false)
			if animationTimer <= 0:
				animationTimer = ANIMATION_DASHING_TIME
			elif animationTimer <= ANIMATION_DASHING_TIME/2:
				$Sprite2D.frame = 31
			elif animationTimer <= ANIMATION_DASHING_TIME:
				$Sprite2D.frame = 30
			elif animationTimer > ANIMATION_DASHING_TIME:
				animationTimer = ANIMATION_DASHING_TIME
		else:
			if animationTimer <= 0:
				animationTimer = ANIMATION_DASHING_TIME
			elif animationTimer <= ANIMATION_DASHING_TIME/2:
				$Sprite2D.frame = 27
			elif animationTimer <= ANIMATION_DASHING_TIME:
				$Sprite2D.frame = 26
			elif animationTimer > ANIMATION_DASHING_TIME:
				animationTimer = ANIMATION_DASHING_TIME
	elif animationState == "attacking":
		$Sprite2D.frame = 0
		$hands.visible = true
		$hands.frame = 10
		if $weapon.position == Vector2(0,-3):
			$weapon.position = Vector2(0,2)
		$weapon.rotation = attackShape.rotation + 0.5 * PI
		$weapon.position = $weapon.position * 0.7 + attackShape.position * 0.3
		if (attackShape.global_position-global_position).angle() >= -5*PI/4 && (attackShape.global_position-global_position).angle() < 0:
			$weapon.z_index = -2
			$Sprite2D.frame = 22
			$hands.visible = false
		else:
			$weapon.z_index = -0
	animationTimer -= delta
	if velocity != Vector2(0,0):
		animationOldAngle = velocity

func weapon_position_idle(inFront):
	$weapon.position = Vector2(0,-3)
	$weapon.rotation_degrees = 0
	if inFront:
		$weapon.z_index = 0
	else:
		$weapon.z_index = -2
