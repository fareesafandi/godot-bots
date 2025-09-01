extends CharacterBody2D
#TODO:
# Use enum state as action.
enum EnemyStates {ATTACK, FLIGHT, DEATH, HIT, PATROL}

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var health = 10
var state = EnemyStates.PATROL
var is_attacking = false
var alt

# Get the gravity from the project settings to be synced with RigidBody nodes.
# var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#Invoked on scene entry
func _ready():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	$AnimatedSprite2D.play("Flight")
	
	#sub state inside patrol method
	alt = true
	#display and initiate text.
	$Health.text = str(health)
	$Health.show()
	

#FPS specific idle processing
func _process(delta):
	pass

#60 interation per second, physics processing
func _physics_process(delta):
	
	#PRESET----------------------------------
	# Add the gravity.
	#if not is_on_floor():
	#	velocity.y += gravity * delta
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	#PRESET----------------------------------
	#Without gravity the character body can be pushed limitlessly.
	#Gravity should exist while character is not moving.
	
	#Stateful movement
	match state:
		EnemyStates.FLIGHT: 
			flying()
		EnemyStates.PATROL:
			patrolling()
		EnemyStates.ATTACK:
			attack()
		EnemyStates.HIT:
			hit()
		EnemyStates.DEATH:
			death()

	#Attack
	if is_attacking: 
		return

func attack():
	#Can't perform movement and attack simultaneously.
	$AnimatedSprite2D.play("Attack")
	print("Attacking")
	await $AnimatedSprite2D.animation_finished
	
	change_state(EnemyStates.FLIGHT)

func hit():
	
	if !$AnimatedSprite2D.animation == "Take Hit":
		health -= 1
	else: 
		return

	print("Health: ", health)
	$AnimatedSprite2D.play("Take Hit")
	$Health.text = str(health)
	$Health.show()
	
	await $AnimatedSprite2D.animation_finished
	
	if health <= 0:
		change_state(EnemyStates.DEATH)
	else: 
		change_state(EnemyStates.FLIGHT)
	
	#await $AnimatedSprite2D.animation_finished
	#if !Input.is_action_just_pressed("main_action"):
	#	change_state(EnemyStates.FLIGHT)
	#if Input.is_action_just_pressed("main_action"):
	#	change_state(EnemyStates.ATTACK)


func death():
	#User input should unresponsive at the time of death.
	$AnimatedSprite2D.play("Death")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.stop()

func flying():
	var direction = Vector2.ZERO
	
	$AnimatedSprite2D.play("Flight")
	if Input.is_action_pressed("move_up"):
		direction.y += -1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1 
		$AnimatedSprite2D.flip_h = false
	if Input.is_action_pressed("move_left"):
		direction.x += -1
		$AnimatedSprite2D.flip_h = true
	
	if direction != Vector2.ZERO:
		direction.normalized()
		
	if Input.is_action_pressed("main_action"):
		change_state(EnemyStates.ATTACK)
	
	velocity = direction * SPEED
	
	move_and_slide()

func change_state(new_state):
	state = new_state
	print("State changed: ", state)
	
func hit_state():
	change_state(EnemyStates.HIT)
	print("Hit state")
	
func fly():
	# Automated fly move, towards player subject. 
	# if detect player AttackArea then attack player. 
	# What should enemy do when not in attack proximity? find enemy?
	pass
	
func patrolling():
	var direction = Vector2.ZERO
	
	if alt: 
		direction.x += 0.3 
		$AnimatedSprite2D.flip_h = true 
		await get_tree().create_timer(2.0).timeout
		alt = false
	else: 
		direction.x += -0.3
		$AnimatedSprite2D.flip_h = false 
		await get_tree().create_timer(2.0).timeout
		alt = true
	
	velocity = direction * SPEED
	move_and_slide()
	
