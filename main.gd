extends Node

@export var coin_scene : PackedScene
@export var powerup_scene : PackedScene
@export var cactus_scene : PackedScene
@export var playtime = 30

var level = 1
var score = 0
var time_left = 0
var screensize = Vector2.ZERO
var playing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
	$Player.hide()
	#new_game()

func new_game():
	playing = true
	level = 1
	score = 0
	time_left = playtime
	$Player.start()	
	$Player.show()
	$GameTimer.start()
	spawn_coins()
	spawn_cactus()
	
	$HUD.update_score(score)
	$HUD.update_timer(time_left)
	
	
func spawn_coins():
	for i in level + 4:
		var c = coin_scene.instantiate()
		add_child(c)
		c.screensize = screensize
		c.position = Vector2(randi_range(0, screensize.x), randi_range(0, screensize.y))
	$LevelSound.play

func spawn_cactus():
	for obstacle in get_tree().get_nodes_in_group("obstacles"):
		obstacle.queue_free()
		
	for i in 2:
		var c = cactus_scene.instantiate()
		add_child(c)
		c.screensize = screensize
		c.position = Vector2(randi_range(0, screensize.x), randi_range(0, screensize.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if playing and get_tree().get_nodes_in_group("coins").size() == 0:
		level += 1
		time_left += 5
		spawn_coins()
		spawn_cactus()
		$PowerupTimer.wait_time = randf_range(5, 10)
		$PowerupTimer.start()
		


func _on_game_timer_timeout():
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left <= 0:
		game_over()

func _on_player_hurt():
	game_over()



func _on_player_pickup(type):
	if type == "coin":
		score += 1
		$HUD.update_score(score)
		$CoinSound.play()
	if type == "powerup":
		$PowerupSound.play()
		time_left += 5
		$HUD.update_timer(time_left)
		
		
func game_over():
	playing = false
	$GameTimer.stop()
	$PowerupTimer.stop()
	get_tree().call_group("coins", "queue_free")
	$EndSound.play()
	$HUD.show_game_over()
	$Player.die()
	
func _on_hud_start_game():
	new_game()
	
func _on_powerup_timer_timeout():
	var p = powerup_scene.instantiate()
	add_child(p)
	p.screensize = screensize
	p.position = Vector2(randi_range(0, screensize.x), randi_range(0, screensize.y))
	
