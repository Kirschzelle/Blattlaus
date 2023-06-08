extends CharacterBody2D

const SPEED = 5000
const KNOCKBACKINTENSITYFACTOR = 1.0 #This sets the ratio at which knockbacks get longer per incresing intensity. Ex. 0.5 would be: if attack is twice as strong, your knockbacked with twice the speed, but only unable to move for 1.5 times the time.
const DASHLENGTH = 0.15
const DASHSPEEDFACTOR = 3

var constSpeedMultiplier = 1.0
var knockBackPercentage = 0.0
var knockBackIntensity = 1.0 #1.0 stands for 1 Second until you are able to completly move again.
var knockBackVelocity = Vector2(0,0)
var knockedBack = false
var dashTimer = 0
var dashSpeedMultiplier = 1.0
var dashLengthMultiplier = 1.0
var dashing = false

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
	if dashing:
		calculate_dash(delta)
	else:
		calculate_input(delta)
		listener_dash()
	move_and_slide()
	
func calculate_input(delta):
	var movementInput = Input.get_vector("ui_left","ui_right", "ui_up", "ui_down") * SPEED * constSpeedMultiplier * delta
	velocity = velocity * knockBackPercentage + movementInput * (1-knockBackPercentage)
	
func init_newKnockBack(inputVector, intensity):
	if inputVector != Vector2(0,0):
		var tempVector = Vector2(0,0)
		if knockBackPercentage * knockBackIntensity <= 1.0 * intensity:
			knockedBack = true
			knockBackIntensity = intensity * KNOCKBACKINTENSITYFACTOR
			knockBackPercentage = 1.0
		knockBackVelocity = knockBackVelocity + tempVector.direction_to(inputVector) * SPEED * intensity
	
func calculate_knockBack(delta):
	if knockedBack:
		if knockBackVelocity != Vector2(0,0):
			velocity = velocity + knockBackVelocity * delta
			knockBackVelocity = Vector2(0,0)
		knockBackPercentage -= (1/knockBackIntensity)*delta
		if knockBackPercentage <= 0:
			knockBackPercentage = 0
			knockedBack = false
			
func listener_dash():
	if Input.get_action_strength("ui_dash") > 0 && velocity != Vector2(0,0) && dashing == false:
		dashing = true
		dashTimer = DASHLENGTH * dashLengthMultiplier
		velocity *= DASHSPEEDFACTOR * dashSpeedMultiplier
			
func calculate_dash(delta):
	dashTimer -= delta
	if dashTimer <= 0:
		dashTimer = 0
		dashing = false
		velocity /= DASHSPEEDFACTOR * dashSpeedMultiplier
