extends "res://enemy/enemy.gd"

const STANDARDATTACKDISTANCE = 20
const ATTACK_IMPACT_TIME = 2

var attackDirection
var attackShape
var attackRangeArea
var inAttackRange = false
var isAttacking = false
var attackDone = false
var attackLength = 0.75
var attackImpact = 0

func _init():
	super()
	attack = 5
	weight = 4
	attackSpeed = 0.75
	detectionRange = 70
	speed = 20
	armor = -1 #-1 stands for no armor
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
		$player_detected.visible = true
		if attackImpact <= 0 && isAttacking:
			if attackCooldown > 0:
				attackCooldown -= delta
			else:
				attackShape.monitoring = true
				update_attack_shape()
	else:
		$player_detected.visible = false
		attackCooldown = attackSpeed

func _physics_process(delta):
	super(delta)
	handle_collision()
	calculate_move(delta)

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

func _player_detected(_body):
	player.init_newKnockBack(player.global_position - global_position, attack)

func _player_in_attack_range(_body):
	inAttackRange = true

func _player_not_in_attack_range(_body):
	inAttackRange = false

func handle_collision():
	for x in get_slide_collision_count():
		var collision_body = get_slide_collision(x)
		if collision_body.get_collider_id() == player.get_instance_id():
			player.init_newKnockBack(player.global_position - global_position, attack)
			init_newKnockBack(global_position - player.global_position, STANDARD_KNOCKBACK/weight)

func calculate_move(delta):
	if inRange && !knockedBack && !isAttacking:
		var moveDirection = (player.position - position).normalized()
		velocity = moveDirection * speed
	velocity *= SPEED_REDUCTION_PRECENTAGE
	move_and_slide()
