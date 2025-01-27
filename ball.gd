extends RigidBody2D

var should_reset = false
var reset_position = Vector2.ZERO

func reset_to(new_position):
  should_reset = true
  reset_position = new_position
  
func _integrate_forces(state:PhysicsDirectBodyState2D):
  if should_reset:
    should_reset = false
    state.transform.origin = reset_position
    state.linear_velocity = Vector2.ZERO
  
