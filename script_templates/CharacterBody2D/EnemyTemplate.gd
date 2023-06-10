# meta-description: Basic script setup for building any enemy. Inherits from enemy/enemy.gd

extends "res://enemy/enemy.gd"

func _init():
	super()
	attack =
	weight =
	attackSpeed =
	detectionRange =
	speed =
	armor = -1 #-1 stands for no armor

func _ready():
	super()

func _process(delta):
	super(delta)
	hande_collision()

func _physics_process(delta):
	super(delta)
	calculate_move(delta)

func hande_collision():
	for x in get_slide_collision_count():
		var collision_body = get_slide_collision(x)
		if collision_body.get_collider_id() == player.get_instance_id():
			#TODO Handle running into player
			pass

func calculate_move(delta):
	#TODO handle movement
	velocity *= SPEED_REDUCTION_PRECENTAGE
	move_and_slide()
