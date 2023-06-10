extends "res://enemy/enemy.gd"

var jumping = false
var jumpTime = 0.5

func _init():
	super()
	attack = 2
	weight = 1
	attackSpeed = 2.5
	armor = -1
	speed = 200
	detectionRange = 100.0
	
func _process(delta):
	super(delta)
	if jumping:
		invincible = true
	else:
		invincible = false
	if inRange:
		$player_detected.visible = true
	else:
		$player_detected.visible = false
		attackCooldown = attackSpeed

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
			attackCooldown = attackSpeed
			jumpTime = 0.5

func calculate_move(delta):
	if jumpTime > 0:
		jumpTime -= delta
	else:
		velocity *= SPEED_REDUCTION_PRECENTAGE
		
	for x in get_slide_collision_count():
		var collision_body = get_slide_collision(x)
		
		if collision_body.get_collider_id() == player.get_instance_id():
			if jumping == false:
				pass
				#TODO play special animation
			player.init_newKnockBack((player.position - position), attack)
			init_newKnockBack(global_position - player.global_position, STANDARD_KNOCKBACK/weight)
			jumping = false
	
	if velocity.x < speed/5 && velocity.x > -speed/5 && velocity.y < speed/5 && velocity.y > -speed/5:
		jumping = false
		
	move_and_slide()
