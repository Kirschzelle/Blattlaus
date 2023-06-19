extends Node2D

@onready
var base = $base
@onready
var tank = $tank
@onready
var hit = $hit
@onready
var edge = $edge

var playTank = false
var playHit = false
var playEdge = false

var stage = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	base.stream = load("res://sound/S0.wav")
	base.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !base.playing:
		match stage:
			0:
				stage = 1
				var slime = load("res://enemy/slime.tscn").instantiate()
				slime.global_position = Vector2(0, 0)
				slime.z_index = 50
				add_sibling(slime)
			1:
				base.stream = load("res://sound/S1_base.wav")
				base.play(0.0)
				if playEdge:
					edge.stream = load("res://sound/S1_edge.wav")
					edge.play(0.0)
					playEdge = false
				if playTank:
					tank.stream = load("res://sound/S1_tank.wav")
					tank.play(0.0)
					playTank = false
				if playHit:
					hit.stream = load("res://sound/S1_hit.wav")
					hit.play(0.0)
					playHit = false
			2:
				base.stream = load("res://sound/S2_base.wav")
				base.play(0.0)
				if playEdge:
					edge.stream = load("res://sound/S2_edge.wav")
					edge.play(0.0)
					playEdge = false
				if playTank:
					tank.stream = load("res://sound/S2_tank.wav")
					tank.play(0.0)
					playTank = false
				if playHit:
					hit.stream = load("res://sound/S2_hit.wav")
					hit.play(0.0)
					playHit = false
			3:
				base.stream = load("res://sound/S3_base.wav")
				base.play(0.0)
				if playEdge:
					edge.stream = load("res://sound/S3_edge.wav")
					edge.play(0.0)
					playEdge = false
				if playTank:
					tank.stream = load("res://sound/S3_tank.wav")
					tank.play(0.0)
					playTank = false
				if playHit:
					hit.stream = load("res://sound/S3_hit.wav")
					hit.play(0.0)
					playHit = false
					
func queueTank():
	playTank = true
	if !tank.playing:
		match stage:
			1:
				tank.stream = load("res://sound/S1_tank.wav")
				tank.play(base.get_playback_position())
				playTank = false
			2:
				tank.stream = load("res://sound/S2_tank.wav")
				tank.play(base.get_playback_position())
				playTank = false
			3:
				tank.stream = load("res://sound/S3_tank.wav")
				tank.play(base.get_playback_position())
				playTank = false

func queueHit():
	playHit = true
	if !hit.playing:
		match stage:
			1:
				hit.stream = load("res://sound/S1_hit.wav")
				hit.play(base.get_playback_position())
				playHit = false
			2:
				hit.stream = load("res://sound/S2_hit.wav")
				hit.play(base.get_playback_position())
				playHit = false
			3:
				hit.stream = load("res://sound/S3_hit.wav")
				hit.play(base.get_playback_position())
				playHit = false

func queueEdge():
	playEdge = true
	if !edge.playing:
		match stage:
			1:
				edge.stream = load("res://sound/S1_edge.wav")
				edge.play(base.get_playback_position())
				playEdge = false
			2:
				edge.stream = load("res://sound/S2_edge.wav")
				edge.play(base.get_playback_position())
				playEdge = false
			3:
				edge.stream = load("res://sound/S3_edge.wav")
				edge.play(base.get_playback_position())
				playEdge = false
