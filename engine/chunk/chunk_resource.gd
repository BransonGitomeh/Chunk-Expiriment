extends Resource

class_name Chunk_Data

const chunk_size = 32
export(Array) var placed_buildings #[position,index]
export(Vector2) var pos
#resources
export(Array) var values
export(OpenSimplexNoise) var noise

func _get_point(position : Vector2) -> Array:
	var point = position - Vector2(1,1) - pos * chunk_size
	var pos_in_array = point.x * chunk_size + point.y
	return [_SimplexNoiseLogic(noise.get_noise_2dv(position)),values[pos_in_array]]

func get_points() -> Array:
	var output := []
	for x in range(chunk_size):
		for y in range(chunk_size):
			var point = Vector2(x,y) + pos * chunk_size + Vector2(1,1)
			var p := _get_point(point)
			output.append([point] + p)
	return output

func get_building(position : Vector2) -> Array:
	for building in placed_buildings:
		if building[0] == position:
			return building
	return []

func get_buildings() -> Array:
	return placed_buildings

func _SimplexNoiseLogic(value : float):
	if value < -0.4:
		return 0 #deep water
	elif value < -0.2:
		return 1 #water
	elif value < 0.4:
		return 2 #grass
	else:
		return 3 #resource
