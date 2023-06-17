extends "res://enemy/enemy.gd"

const ANIMATION_IDLE_LOOP_TIME = 0.25

var timeUntilScanningForEnemys = 5
var rotationSpeedFactor = 0.1
var parent
var pendingDelete = false
var animationState = "idle"
var animationTimer = 0.0
var aggroStage = 0

func _init():
	super()
	weight = 1
	attackSpeed = 1
	detectionRange = 70
	armor = -1
	
func _ready():
	super()
	
func _process(delta):
	super(delta)
	handle_collision()
	if timeUntilScanningForEnemys > 0:
		timeUntilScanningForEnemys -= delta
		if timeUntilScanningForEnemys <= 0:
			collision_mask = CollisionLayers.COLLISION_LAYER_PLAYER + CollisionLayers.COLLISION_LAYER_ENEMY
	animate(delta)

func handle_collision():
	for x in get_slide_collision_count():
		var collision_body = get_slide_collision(x)
		if collision_body.get_collider_id() == player.get_instance_id() && !pendingDelete:
			player.init_newKnockBack(player.global_position - global_position, attack)
			deleteNode()
		elif !pendingDelete:
			collision_body.get_collider().init_newKnockBack(collision_body.get_collider().global_position - global_position, attack)
			deleteNode()
	
func _physics_process(delta):
	super(delta)
	if knockedBack:
		deleteNode()
	calculate_move(delta)
	
func calculate_move(delta):
	if inRange:
		rotation = (global_position - player.global_position).angle() - 0.5 * PI
		#TODO make rotation gradual
	velocity = Vector2(cos(deg_to_rad(360 - rotation_degrees + 90)), -sin(deg_to_rad(360 - rotation_degrees + 90))).normalized() * speed
	move_and_slide()

func deleteNode():
	parent.bulletAmount -= 1
	queue_free()
	pendingDelete = true

func animate(delta):
	if animationTimer <= 0:
		animationTimer = ANIMATION_IDLE_LOOP_TIME
		$Sprite2D.frame += 1
		if $Sprite2D.frame >= 4:
			$Sprite2D.frame = 0
		if inRange && aggroStage < 4:
			$mouth.frame += 1
			aggroStage += 1
		elif !inRange && aggroStage > 0:
			$mouth.frame -= 1
			aggroStage -= 1
		if $mouth.frame == 4:
			$mouth.visible = false
		else:
			$mouth.visible = true
	animationTimer -= delta
