extends CharacterBody2D

const SPEED = 5000
const KNOCKBACKINTENSITYFACTOR = 1.0 #This sets the ratio at which knockbacks get longer per incresing intensity. Ex. 0.5 would be: if attack is twice as strong, your knockbacked with twice the speed, but only unable to move for 1.5 times the time.

var constSpeedMultiplier = 1.0
var knockBackPercentage = 0.0
var knockBackIntensity = 1.0 #1.0 stands for 1 Second until you are able to completly move again.
var knockedBack = false
var activeInput = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(delta):
	calculate_movement(delta)

func calculate_movement(delta):
	calculate_knockBack(delta)
	calculate_input(delta)
	move_and_slide()
	
func calculate_input(delta):
	var movementInput = Input.get_vector("ui_left","ui_right", "ui_up", "ui_down") * SPEED * constSpeedMultiplier * delta
	velocity = velocity * knockBackPercentage + movementInput * (1-knockBackPercentage)
	
func init_newKnockBack(vector, intensity):
	if vector != Vector2(0,0):
		if knockBackPercentage * knockBackIntensity <= 1.0 * intensity:
			knockedBack = true
			knockBackIntensity = intensity * KNOCKBACKINTENSITYFACTOR
			knockBackPercentage = 1.0
			velocity = velocity + vector.direction_to(vector) * SPEED * intensity
		else:
			velocity = velocity + vector.direction_to(vector) * SPEED * intensity
	
func calculate_knockBack(delta):
	if knockedBack:
		knockBackPercentage -= (1/knockBackIntensity)*delta
		if knockBackPercentage <= 0:
			knockBackPercentage = 0
			knockedBack = false
