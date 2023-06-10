extends "res://enemy/enemy.gd"

const BULLET_SPAWN_DISTANCE = 25

var maxBullets = 10
var bulletAmount = 0
var bullet = preload("res://enemy/eye_bullet.tscn")

func _init():
	super()
	attack = 1.5
	weight = 3
	attackSpeed = 0.25
	detectionRange = 150
	armor = -1
	speed = 30
	
func _process(delta):
	if inRange:
		$player_detected.visible = true
		attackCooldown -= delta
		if attackCooldown <= 0:
			if bulletAmount < maxBullets-1:
				attackCooldown = attackSpeed
			else:
				attackCooldown = attackSpeed * 20
			spawn_bullet()
		elif attackCooldown > attackSpeed && bulletAmount < maxBullets-1:
			attackCooldown = attackSpeed
	else:
		$player_detected.visible = false
	
	
func _physics_process(delta):
	super(delta)
	calculate_move(delta)
	hande_collision()

func hande_collision():
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
	newBullet.speed = speed
	newBullet.parent = self
	newBullet.rotation = (player.global_position - global_position).angle() + (0.5* PI)
	newBullet.position = position + (player.global_position - global_position).normalized() * BULLET_SPAWN_DISTANCE
	bulletAmount += 1
	add_sibling(newBullet)
