extends "res://enemy/enemy.gd"

const BULLET_SPAWN_DISTANCE = 0
const ANIMATION_IDLE_LOOP_TIME = 1.0
const ANIMATION_PHASE_OUT_TIME_PER_FRAME = 0.25
const OUTSIDE_RANGE_FACTOR = 1.5

var maxBullets = 15
var bulletAmount = 0
var bullet = preload("res://enemy/eye_bullet.tscn")
var animationState = "idle"
var animationTimer = 0.0
var phaseOutState = 0
var particleStage = false

func _init():
	super()
	attack = 4
	weight = 3
	attackSpeed = 0.25
	detectionRange = 100
	armor = -1
	speed = 40
	type = "eye"
	
func _process(delta):
	if inRange:
		if attackCooldown <= attackSpeed * OUTSIDE_RANGE_FACTOR:
			animationState = "attacking"
		attackCooldown -= delta
		if attackCooldown <= 0:
			if bulletAmount < maxBullets-1:
				attackCooldown = attackSpeed
			else:
				attackCooldown = attackSpeed * OUTSIDE_RANGE_FACTOR * 4
				animationState = "coolingDown"
				phaseOutState = 7
			spawn_bullet()
		elif attackCooldown > attackSpeed * OUTSIDE_RANGE_FACTOR && bulletAmount < maxBullets-1:
			attackCooldown = attackSpeed * OUTSIDE_RANGE_FACTOR
	else:
		if animationState == "attacking":
			animationState = "coolingDown"
			phaseOutState = 7
		attackCooldown = attackSpeed * OUTSIDE_RANGE_FACTOR
	animate(delta)
	
	
func _physics_process(delta):
	super(delta)
	calculate_move(delta)
	handle_collision()

func handle_collision():
	for x in get_slide_collision_count():
		var collision_body = get_slide_collision(x)
		if collision_body.get_collider_id() == player.get_instance_id():
			player.init_newKnockBack(player.global_position - global_position, attack)
			init_newKnockBack(global_position - player.global_position, STANDARD_KNOCKBACK/weight)

func calculate_move(delta):
	velocity *= SPEED_REDUCTION_PRECENTAGE
	move_and_slide()

func spawn_bullet():
	var newBullet = bullet.instantiate()
	newBullet.attack = attack
	newBullet.z_index = z_index
	newBullet.speed = speed + bulletAmount
	newBullet.parent = self
	newBullet.rotation = (player.global_position - global_position).angle() + (0.5* PI)
	newBullet.position = position + Vector2(0,10)
	bulletAmount += 1
	add_sibling(newBullet)
	playSound()

func animate(delta):
	if animationState == "idle":
		if animationTimer <= 0:
			animationTimer = ANIMATION_IDLE_LOOP_TIME
		elif animationTimer <= ANIMATION_IDLE_LOOP_TIME/2:
			$Sprite2D.frame = 2
		else:
			$Sprite2D.frame = 1
	if animationState == "attacking":
		if attackCooldown <= (attackSpeed*OUTSIDE_RANGE_FACTOR)/4:
			$Sprite2D.frame = 6
		elif attackCooldown <= 2*(attackSpeed*OUTSIDE_RANGE_FACTOR)/4: 
			$Sprite2D.frame = 5
		elif attackCooldown <= 3*(attackSpeed*OUTSIDE_RANGE_FACTOR)/4: 
			$Sprite2D.frame = 4
		else:
			$Sprite2D.frame = 3
	if animationState == "coolingDown":
		if phaseOutState == 0:
			animationState = "idle"
		elif phaseOutState == 1:
			$Sprite2D.frame = 12
		elif phaseOutState == 2:
			$Sprite2D.frame = 11
		elif phaseOutState == 3:
			$Sprite2D.frame = 10
		elif phaseOutState == 4:
			$Sprite2D.frame = 9
		elif phaseOutState == 5:
			$Sprite2D.frame = 8
		elif phaseOutState == 6:
			$Sprite2D.frame = 7
		if animationTimer <= 0:
			animationTimer = ANIMATION_PHASE_OUT_TIME_PER_FRAME
			phaseOutState -= 1
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

func playSound():
	$spawn.play(0.13)
