extends Node

const eight_directions :=   [
							Vector2(0,1),Vector2(-1,1),Vector2(1,1),
							Vector2(0,-1),Vector2(-1,-1),Vector2(1,-1),
							Vector2(1,0),Vector2(-1,0)
							]

func floor_Vector2(vec : Vector2):
	return Vector2(floor(vec.x),floor(vec.y))

func round_Vector2(vec : Vector2):
    return Vector2(round(vec.x),round(vec.y))

