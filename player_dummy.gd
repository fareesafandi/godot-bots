extends CharacterBody2D

signal hit_enemy



const SPEED = 300.0
const JUMP_VELOCITY = -400.0

enum PLAYER_STATES {IDLE, WALK, ATTACK, SHIELD, TAKEHIT, DEATH}
var health = 500
var state = PLAYER_STATES.IDLE

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	match state: 
		PLAYER_STATES.IDLE: 
			idling()
		PLAYER_STATES.WALK: 
			walking()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	

func walking():
	
	var direction = Vector2.ZERO
	
	$AnimatedSprite2D.play("walk")
	if Input.is_action_pressed("move_right"):
		direction.x += 0.5
		$AnimatedSprite2D.flip_h = false
	if Input.is_action_pressed("move_left"):
		direction.x = -0.5 
		$AnimatedSprite2D.flip_h = true
		
	velocity = direction * SPEED
	
	move_and_slide()
	
func idling():
	$AnimatedSprite2D.play("idle")
	

func _on_damage_area_entered(area):
	#Triggered on other Area2D overlapping.
	#TODO: not detecting anything.
	if $DamageArea.is_in_group("enemy"):
		emit_signal("hit_enemy")
		print("enemy is in area")

	#When enemy group enter this area, will signal the enemy class to take damage.
