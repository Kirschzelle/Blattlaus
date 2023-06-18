extends "res://enemy/enemy.gd"

const STANDARDATTACKDISTANCE = 20
const ATTACK_IMPACT_TIME = 2
const ANIMATION_IDLE_LOOP_TIME = 1.0
const ANIMATION_WALKING_LOOP_TIME = 1.0

var attackDirection
var attackShape
var attackRangeArea
var inAttackRange = false
var isAttacking = false
var attackDone = false
var attackLength = 0.75
var attackImpact = 0
var animationState = "idle"
var animationTimer = 0.0
var oldVelocity = Vector2(0,1)
var particleStage = false

func _init():
	super()
	attack = 5
	weight = 4
	attackSpeed = 0.75
	detectionRange = 100
	speed = 20
	armor = -1 #-1 stands for no armor
	type = "heavyFighter"
	create_attack_shape()
	create_attack_range()

func _ready():
	super()
	attackShape.body_entered.connect(_player_detected, player.get_instance_id())
	attackRangeArea.body_entered.connect(_player_in_attack_range, player.get_instance_id())
	attackRangeArea.body_exited.connect(_player_not_in_attack_range, player.get_instance_id())

func _process(delta):
	super(delta)
	if inAttackRange && !isAttacking:
		isAttacking = true
		attackDirection = (player.position - position).normalized()
	if attackImpact > 0:
		attackImpact -= delta
	elif attackDone:
		isAttacking = false
		attackDone = false
		attackShape.monitoring = false
	if inRange:
		if attackImpact <= 0 && isAttacking:
			if attackCooldown > 0:
				attackCooldown -= delta
			else:
				attackShape.monitoring = true
				update_attack_shape()
	else:
		attackCooldown = attackSpeed
		
	if spawnEye:
		spawn_eye()

func _physics_process(delta):
	super(delta)
	handle_collision()
	calculate_move(delta)
	animate(delta)

func create_attack_range():
	attackRangeArea = Area2D.new()
	add_child(attackRangeArea)
	var attackRangeShape = CollisionShape2D.new()
	var attackRangeCircle = CircleShape2D.new()
	attackRangeCircle.radius = 60
	attackRangeShape.shape = attackRangeCircle
	attackRangeArea.collision_mask = CollisionLayers.COLLISION_LAYER_PLAYER
	attackRangeArea.collision_layer =  0
	attackRangeArea.add_child(attackRangeShape)

func create_attack_shape():
	attackShape = Area2D.new()
	add_child(attackShape)
	collisionShape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 20)
	collisionShape.shape = shape
	attackShape.add_child(collisionShape)
	attackShape.position = velocity.normalized()
	attackShape.collision_layer = 0
	attackShape.collision_mask = CollisionLayers.COLLISION_LAYER_PLAYER
	attackShape.monitorable = false
	attackShape.monitoring = false

func update_attack_shape():
	attackShape.position = attackDirection * STANDARDATTACKDISTANCE
	attackShape.rotation = attackDirection.angle()
	attackCooldown = attackSpeed
	attackImpact = ATTACK_IMPACT_TIME
	attackDone = true
	
func spawn_eye():
	var eye = preload("res://enemy/eye.tscn").instantiate()
	eye.global_position = Vector2(0,0)
	eye.z_index = 50
	add_sibling(eye)
	spawnEye = false
	queue_free()
	
func _player_detected(_body):
	player.init_newKnockBack(player.global_position - global_position, attack)
	attackShape.body_entered.connect(_player_detected, player.get_instance_id())

func _player_in_attack_range(_body):
	inAttackRange = true
	attackRangeArea.body_entered.connect(_player_in_attack_range, player.get_instance_id())

func _player_not_in_attack_range(_body):
	inAttackRange = false
	attackRangeArea.body_exited.connect(_player_not_in_attack_range, player.get_instance_id())

func handle_collision():
	for x in get_slide_collision_count():
		var collision_body = get_slide_collision(x)
		if collision_body.get_collider_id() == player.get_instance_id():
			player.init_newKnockBack(player.global_position - global_position, attack)
			init_newKnockBack(-(player.global_position - global_position), STANDARD_KNOCKBACK/weight)

func calculate_move(delta):
	if inRange && !knockedBack && !isAttacking:
		var moveDirection = (player.position - position).normalized()
		velocity = moveDirection * speed
		oldVelocity = velocity
		animationState = "moving"
	else:
		animationState = "idle"
	velocity *= SPEED_REDUCTION_PRECENTAGE
	move_and_slide()

func animate(delta):
	if animationState == "idle":
		if oldVelocity.angle() < PI/2 && oldVelocity.angle() > -PI/4:
			if animationTimer <= 0:
				animationTimer = ANIMATION_IDLE_LOOP_TIME
			elif animationTimer <= ANIMATION_IDLE_LOOP_TIME/2:
				$Sprite2D.frame = 10
			else:
				$Sprite2D.frame = 9
		elif oldVelocity.angle() > -3*PI/4 && oldVelocity.angle() <= -PI/4:
			if animationTimer <= 0:
				animationTimer = ANIMATION_IDLE_LOOP_TIME
			elif animationTimer <= ANIMATION_IDLE_LOOP_TIME/2:
				$Sprite2D.frame = 8
			else:
				$Sprite2D.frame = 7
		else:
			if animationTimer <= 0:
				animationTimer = ANIMATION_IDLE_LOOP_TIME
			elif animationTimer <= ANIMATION_IDLE_LOOP_TIME/2:
				$Sprite2D.frame = 1
			else:
				$Sprite2D.frame = 0
	if animationState == "moving":
		if oldVelocity.angle() < PI/2 && oldVelocity.angle() > -PI/4:
			if animationTimer <= 0:
				animationTimer = ANIMATION_WALKING_LOOP_TIME
			elif animationTimer <= ANIMATION_WALKING_LOOP_TIME/4:
				$Sprite2D.frame = 15
			elif animationTimer <= ANIMATION_WALKING_LOOP_TIME/2:
				$Sprite2D.frame = 14
			elif animationTimer <= 3*ANIMATION_WALKING_LOOP_TIME/4:
				$Sprite2D.frame = 13
			else:
				$Sprite2D.frame = 12
		elif oldVelocity.angle() > -3*PI/4 && oldVelocity.angle() <= -PI/4:
			if animationTimer <= 0:
				animationTimer = ANIMATION_WALKING_LOOP_TIME
			elif animationTimer <= ANIMATION_WALKING_LOOP_TIME/4:
				$Sprite2D.frame = 21
			elif animationTimer <= ANIMATION_WALKING_LOOP_TIME/2:
				$Sprite2D.frame = 20
			elif animationTimer <= 3*ANIMATION_WALKING_LOOP_TIME/4:
				$Sprite2D.frame = 19
			else:
				$Sprite2D.frame = 18
		else:
			if animationTimer <= 0:
				animationTimer = ANIMATION_WALKING_LOOP_TIME
			elif animationTimer <= ANIMATION_WALKING_LOOP_TIME/4:
				$Sprite2D.frame = 6
			elif animationTimer <= ANIMATION_WALKING_LOOP_TIME/2:
				$Sprite2D.frame = 5
			elif animationTimer <= 3*ANIMATION_WALKING_LOOP_TIME/4:
				$Sprite2D.frame = 4
			else:
				$Sprite2D.frame = 3
	animationTimer -= delta

func gotHit():
	if particleStage:
		if $blood2.emitting == false:
			$blood.emitting = true
			particleStage = false
	else:
		if $blood.emitting == false:
			$blood2.emitting = true
			particleStage = true
