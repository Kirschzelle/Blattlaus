extends CharacterBody2D

const ENEMYKNOCKBACKTIMEREDUCTION = 10
const SPEED_REDUCTION_PRECENTAGE = 0.95
const STANDARD_KNOCKBACK = 1

#init in specific enemy script (_init():) you have to call super() function!
#Start of things to init
var attack
var weight
var attackSpeed
var armor
var detectionRange
var speed
var type
#End of things to init

var spawnEye = false

var attackCooldown = 999
var knockBackPercentage = 0.0
var knockBackIntensity = 1.0 #1.0 stands for 1 Second until you are able to completly move again.
var knockBackVelocity = Vector2(0,0)
var knockedBack = false
var invincible = false

#use in specific enemy script
var inRange = false
@onready
var player = $/root/parent/player

#internal vars
var collisionShape
var detectionArea
var circle

func _ready():
	circle.radius = detectionRange
	detectionArea.monitorable = false
	detectionArea.body_entered.connect(_player_entered_detection_area,player.get_instance_id())
	detectionArea.body_exited.connect(_player_exited_detection_area,player.get_instance_id())
	$/root/parent/sandAreaEnemy.body_exited.connect(_enemy_exited_sand_area, get_instance_id())
	player.init_new_enemy(self)
	attackCooldown = attackSpeed

func _init():
	detectionArea = Area2D.new()
	add_child(detectionArea)
	collisionShape = CollisionShape2D.new()
	circle = CircleShape2D.new()
	collisionShape.shape = circle
	detectionArea.collision_mask = CollisionLayers.COLLISION_LAYER_PLAYER
	detectionArea.collision_layer =  0
	detectionArea.add_child(collisionShape)

func _process(_delta):
	pass

func _physics_process(delta):
	calculate_knockBack(delta)

func init_newKnockBack(inputVector, intensity):
	if inputVector != Vector2(0,0) && !invincible:
		var tempVector = Vector2(0,0)
		if knockBackPercentage * knockBackIntensity <= 1.0 * intensity:
			knockedBack = true
			knockBackIntensity = (intensity * player.KNOCKBACKINTENSITYFACTOR)/weight
			knockBackPercentage = 1.0
		knockBackVelocity = knockBackVelocity + tempVector.direction_to(inputVector) * player.SPEED * intensity

func calculate_knockBack(delta):
	if knockedBack:
		if knockBackVelocity != Vector2(0,0):
			velocity = velocity + knockBackVelocity
			knockBackVelocity = Vector2(0,0)
		knockBackPercentage -= delta
		if velocity == Vector2(0,0):
			knockedBack = false
		if knockBackPercentage <= 0:
			knockBackPercentage = 0
			knockedBack = false
			
func _player_entered_detection_area(_body):
	inRange = true #TODO check if next line leads to memory leak (aka try to detach first)
	detectionArea.body_entered.connect(_player_entered_detection_area,player.get_instance_id())
	
func _player_exited_detection_area(_body):
	inRange = false
	detectionArea.body_exited.connect(_player_exited_detection_area,player.get_instance_id())

func _enemy_exited_sand_area(_body):
	match type:
		"slime":
			spawn_heavy_fighter()
		"heavyFighter":
			spawnEye = true
		"eye":
			eye_defeated()
	
	if type != "heavyFighter":
		queue_free()

func spawn_heavy_fighter():
	var heavyFighter = preload("res://enemy/heavy_fighter.tscn").instantiate()
	heavyFighter.global_position = Vector2(0, 0)
	heavyFighter.z_index = 50
	add_sibling(heavyFighter)
	
func eye_defeated():
	pass
