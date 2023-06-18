extends "res://enemy/enemy.gd"

const ANIMATION_IDLE_LOOP_TIME = 1.0
const JUMPING_TIME = 0.5
var jumping = false
var jumpTime = 0.5
var animationState = "idle"
var animationTimer = 0
var attackRest = 1
var specialAnimationTime = 0
const SPECIAL_ANIMATION_DURATION = 0.25
var right = false
var particleStage = false

func _init():
	super()
	attack = 2
	weight = 1
	attackSpeed = 1.5
	armor = -1
	speed = 200
	detectionRange = 100.0
	type = "slime"
	
func _process(delta):
	super(delta)
	if jumping:
		invincible = true
	else:
		invincible = false
	if !inRange:
		attackCooldown = attackSpeed
		
	animateCalc(delta)
	animate(delta)

func _physics_process(delta):
	super(delta)
	calculate_jump(delta)
	calculate_move(delta)

func calculate_jump(delta):
	if inRange:
		if attackCooldown > 0:
			attackCooldown -= delta
		elif !knockedBack:
			var direction = (player.position - position).normalized()
			velocity = direction * speed
			jumping = true
			attackCooldown = attackSpeed + attackRest + JUMPING_TIME
			jumpTime = JUMPING_TIME

func calculate_move(delta):
	if jumpTime > 0:
		jumpTime -= delta
	else:
		velocity *= SPEED_REDUCTION_PRECENTAGE
		
	for x in get_slide_collision_count():
		var collision_body = get_slide_collision(x)
		if collision_body.get_collider_id() == player.get_instance_id():
			if jumping == false:
				specialAnimationTime = SPECIAL_ANIMATION_DURATION
			player.init_newKnockBack((player.position - position), attack)
			init_newKnockBack(global_position - player.global_position, STANDARD_KNOCKBACK/weight)
			jumping = false
			if particleStage:
				if $blood2.emitting == false:
					$blood.emitting = true
					particleStage = false
			else:
				if $blood.emitting == false:
					$blood2.emitting = true
					particleStage = true
	
	if velocity.x < speed/5 && velocity.x > -speed/5 && velocity.y < speed/5 && velocity.y > -speed/5:
		jumping = false
		
	move_and_slide()

func animateCalc(delta):
	if specialAnimationTime > 0:
		specialAnimationTime -= delta
		animationState = "specialAnimationTime"
	elif knockedBack:
		animationState = "knockedBack"
	elif attackCooldown == attackSpeed:
		animationState = "idle"
		if (player.global_position - global_position).angle() < PI/2 && (player.global_position - global_position).angle() > -PI/2:
			right = true
		else:
			right = false
	elif attackCooldown < attackSpeed:
		animationState = "attacking"
	elif jumping:
		animationState = "jumping"
	elif attackCooldown > attackSpeed:
		if (player.global_position - global_position).angle() < PI/2 && (player.global_position - global_position).angle() > -PI/2:
			right = true
		else:
			right = false
		animationState = "coolDown"

func animate(delta):
	if animationState == "idle":
		if animationTimer <= 0:
			animationTimer = ANIMATION_IDLE_LOOP_TIME
		elif animationTimer <= ANIMATION_IDLE_LOOP_TIME/2:
			if right:
				$Sprite2D.frame = 1
			else: 
				$Sprite2D.frame = 12
		else:
			if right:
				$Sprite2D.frame = 0
			else: 
				$Sprite2D.frame = 11
	elif animationState == "attacking":
		if attackCooldown <= attackSpeed/3:
			if right:
				$Sprite2D.frame = 4
			else: 
				$Sprite2D.frame = 15
		elif attackCooldown <= 2*attackSpeed/3:
			if right:
				$Sprite2D.frame = 3
			else: 
				$Sprite2D.frame = 14
		else:
			if right:
				$Sprite2D.frame = 2
			else: 
				$Sprite2D.frame = 13
	elif animationState == "jumping":
		if jumpTime <= JUMPING_TIME/4:
			if right:
				$Sprite2D.frame = 8
			else: 
				$Sprite2D.frame = 19
		elif jumpTime <= JUMPING_TIME/2:
			if right:
				$Sprite2D.frame = 7
			else: 
				$Sprite2D.frame = 18
		elif jumpTime <= 3*JUMPING_TIME/4:
			if right:
				$Sprite2D.frame = 6
			else: 
				$Sprite2D.frame = 17
		else:
			if right:
				$Sprite2D.frame = 5
			else: 
				$Sprite2D.frame = 16
	elif animationState == "coolDown":
		if attackCooldown <= attackSpeed + attackRest/2:
			if right:
				$Sprite2D.frame = 10
			else: 
				$Sprite2D.frame = 21
		else:
			if particleStage:
				if $blood2.emitting == false:
					$blood.emitting = true
					particleStage = false
			else:
				if $blood.emitting == false:
					$blood2.emitting = true
					particleStage = true
			if right:
				$Sprite2D.frame = 9
			else: 
				$Sprite2D.frame = 20
	elif animationState == "knockedBack":
		if animationTimer <= 0:
			animationTimer = ANIMATION_IDLE_LOOP_TIME
		elif animationTimer <= ANIMATION_IDLE_LOOP_TIME/2:
			if right:
				$Sprite2D.frame = 25
			else: 
				$Sprite2D.frame = 29
		else:
			if right:
				$Sprite2D.frame = 24
			else: 
				$Sprite2D.frame = 28
	elif animationState == "specialAnimationTime":
		if specialAnimationTime <= SPECIAL_ANIMATION_DURATION/2:
			if right:
				$Sprite2D.frame = 23
			else: 
				$Sprite2D.frame = 27
		else:
			if right:
				$Sprite2D.frame = 22
			else: 
				$Sprite2D.frame = 26
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
