extends Node2D

var paddle_speed = 250
var ball_velocity = 300
var starting_arc = deg_to_rad(60)
var strike_speed_increase = 1.2
var paused = false
var player_score = 0
var computer_score = 0
var ball_start_position = Vector2.ZERO

func _ready():
  if OS.get_name()=="HTML5":
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
  ball_start_position = $Ball.position
  reset_game()

func reset_game():
  paused = true
  $Ball.reset_to(ball_start_position)
  $PlayerScore.text = str(player_score)
  $ComputerScore.text = str(computer_score)
  $ResetTimer.start()
  
func _on_reset_timer_timeout():
  paused = false
  $Ball.linear_velocity = Vector2(-ball_velocity, 0) \
    .rotated(randf_range(-starting_arc/2, starting_arc/2))

func _process(delta):
  var player_paddle_velocity = 0
  var computer_paddle_velocity = 0
  
  if paused:
    return
  
  # Paddle movement
  if Input.is_action_pressed("Down") \
      and not $BottomBound/Area2D.overlaps_area($PlayerPaddle/Area2D):
    $PlayerPaddle.position.y += delta*paddle_speed
    player_paddle_velocity = paddle_speed
  elif Input.is_action_pressed("Up") \
      and not $TopBound/Area2D.overlaps_area($PlayerPaddle/Area2D):
    $PlayerPaddle.position.y -= delta*paddle_speed
    player_paddle_velocity = -paddle_speed
    
  if $Ball.position.y < $ComputerPaddle.position.y + $ComputerPaddle.scale.y/2 \
      and not $TopBound/Area2D.overlaps_area($ComputerPaddle/Area2D):
    $ComputerPaddle.position.y -= delta*paddle_speed
    computer_paddle_velocity = -paddle_speed
  elif $Ball.position.y > $ComputerPaddle.position.y + $ComputerPaddle.scale.y/2 \
      and not $BottomBound/Area2D.overlaps_area($ComputerPaddle/Area2D):
    $ComputerPaddle.position.y += delta*paddle_speed
    computer_paddle_velocity = paddle_speed
  
  # Bounce off bounds
  if $TopBound/Area2D.overlaps_body($Ball) and $Ball.linear_velocity.y < 0:
    $Ball.linear_velocity.y = abs($Ball.linear_velocity.y)
  if $BottomBound/Area2D.overlaps_body($Ball) and $Ball.linear_velocity.y > 0:
    $Ball.linear_velocity.y = -abs($Ball.linear_velocity.y)
    
  # Bounce off paddles
  if $PlayerPaddle/Area2D.overlaps_body($Ball) and $Ball.linear_velocity.x < 0:
    $Ball.linear_velocity.x = abs($Ball.linear_velocity.x)
    $Ball.linear_velocity *= strike_speed_increase
    $Ball.linear_velocity.y += player_paddle_velocity
  if $ComputerPaddle/Area2D.overlaps_body($Ball) and $Ball.linear_velocity.x > 0:
    $Ball.linear_velocity.x = -abs($Ball.linear_velocity.x)
    $Ball.linear_velocity *= strike_speed_increase
    $Ball.linear_velocity.y += computer_paddle_velocity
  
  if $PlayerGoal.overlaps_body($Ball):
    computer_score += 1
    reset_game()
  elif $ComputerGoal.overlaps_body($Ball):
    player_score += 1
    reset_game()
    
    
  

