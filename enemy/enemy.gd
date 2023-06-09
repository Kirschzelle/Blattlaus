extends CharacterBody2D

#init in specific enemy script
var attack
var weight
var attackSpeed
var attackCooldown
var armor
var detectionRange

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

func _init():
	detectionArea = Area2D.new()
	add_child(detectionArea)
	collisionShape = CollisionShape2D.new()
	circle = CircleShape2D.new()
	collisionShape.shape = circle
	detectionArea.collision_mask = CollisionLayers.COLLISION_LAYER_PLAYER
	detectionArea.collision_layer =  0
	detectionArea.add_child(collisionShape)

func _player_entered_detection_area(_body):
	inRange = true
	
func _player_exited_detection_area(_body):
	inRange = false
