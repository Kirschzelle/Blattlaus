# meta-description: Basic script setup for building any enemy. Inherits from enemy/enemy.gd

extends "res://enemy/enemy.gd"

func _init():
	super()
	attack =
	weight =
	attackSpeed =
	detectionRange =
	armor =
	
func _process(delta):
	pass
	
func _physics_process(delta):
	calculate_move(delta)
	
func calculate_move(delta):
	#Your code here
	move_and_slide()
