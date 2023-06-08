extends CharacterBody2D

const SPEED = 80
var constSpeedMultiplier = 1.0
var konckBackPercentage = 0.0
var activeInput = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(_delta):
	calculate_movement(_delta)

func calculate_movement(_delta):
	var movementInput = Input.get_vector("ui_left","ui_right", "ui_up", "ui_down") * SPEED * constSpeedMultiplier
	velocity = velocity * konckBackPercentage + movementInput * (1-konckBackPercentage)
	move_and_slide()
