extends "res://enemy/enemy.gd"

var timeUntilScanningForEnemys = 1
var rotationSpeedFactor = 0.1
var parent
var pendingDelete = false

func _init():
	super()
	weight = 1
	attackSpeed = 1
	detectionRange = 100
	armor = -1
	
func _ready():
	super()
	
func _process(delta):
	super(delta)
	hande_collision()
	if timeUntilScanningForEnemys > 0:
		timeUntilScanningForEnemys -= delta
		if timeUntilScanningForEnemys <= 0:
			collision_mask = CollisionLayers.COLLISION_LAYER_PLAYER + CollisionLayers.COLLISION_LAYER_ENEMY

func hande_collision():
	for x in get_slide_collision_count():
		var collision_body = get_slide_collision(x)
		if collision_body.get_collider_id() == player.get_instance_id() && !pendingDelete:
			player.init_newKnockBack(player.global_position - global_position, attack)
			deleteNode()
		elif collision_body.get_collider_id() == parent.get_instance_id() && !pendingDelete:
			parent.init_newKnockBack(parent.global_position - global_position, attack)
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
