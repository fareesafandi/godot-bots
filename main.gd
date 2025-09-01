extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func new_game():
	#Called in initialization.
	pass

func start_bot():
	#construct timer to perform automated action.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_hit_enemy():
	$EnemyBots.hit_state()
	
