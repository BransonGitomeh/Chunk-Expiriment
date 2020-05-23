extends Node

var chunks_path : String
var opened_chunk : Resource
var chunk_name : String
const chunk_size = 32
var generation_seed := 0
var simplexnoise = OpenSimplexNoise.new()
var loaded_chunks = []

func _ready():
	generation_seed = randi()
	simplexnoise.seed = generation_seed

#filesystem
##########################################################################################
func set_path(path : String) -> void:
	var directory = Directory.new()
	directory.make_dir(path)
	chunks_path = path

func _open_chunk(chunk_pos : Vector2) -> void:
	var file_list = _list_files_in_directory(chunks_path)
	for chunk in file_list:
		if ResourceLoader.exists(chunks_path.plus_file(chunk)):
			var chunk_res = ResourceLoader.load(chunks_path.plus_file(chunk))
			if chunk_res.pos ==  chunk_pos:
				opened_chunk = chunk_res
				chunk_name = chunk
				return
	# if doesnt find a chunk, creates a new one
	var name = str(file_list.size())
	var chunk = Chunk_Data.new()
	chunk.pos = chunk_pos
	chunk.noise = simplexnoise
	chunk.values = _generate_chunk(chunk_pos)
	opened_chunk = chunk
	var error = ResourceSaver.save(chunks_path.plus_file(name + ".res"),chunk)
	if error != OK:
		print("error while saving new chunk")

func _list_files_in_directory(path) -> Array:
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files
##########################################################################################


#functionality
##########################################################################################
func _load_chunk(position : Vector2) -> void:
	_open_chunk(position)
	loaded_chunks.append(opened_chunk)

func _unload_chunk(position : Vector2) -> void:
	_open_chunk(position)
	if ResourceSaver.save(chunks_path.plus_file(chunk_name),opened_chunk) != OK:
		print("errpr - unable to save chunk while unloading")
	for chunk in loaded_chunks:
		if chunk.pos == position:
			loaded_chunks.erase(chunk)
			return

func _open_loaded_chunk(position : Vector2):
	for chunk in loaded_chunks:
		if chunk.pos == position:
			opened_chunk = chunk
			return
	print("error - chunk not loaded")

func _close_loaded_chunk() -> void:
	for loaded_chunk in loaded_chunks:
		if loaded_chunk.pos == opened_chunk.pos:
			loaded_chunk = opened_chunk

func _get_loaded_chunk(position : Vector2) -> Array:
	for chunk in loaded_chunks:
		if chunk.pos == position:
			return chunk
	return []

func _if_loaded(position : Vector2) -> bool:
	for chunk in loaded_chunks:
		if chunk.pos == position:
			return true
	return false

func _manage_load(positions : Array) -> Array:
	var chunks_to_load := []
	var chunks_to_unload := []
	for position in positions:
		if not _if_loaded(position):
			_load_chunk(position)
			_open_loaded_chunk(position)
			chunks_to_load.append(opened_chunk)
	for chunk in loaded_chunks:
		if not chunk.pos in positions:
			_unload_chunk(chunk.pos)
			chunks_to_unload.append(chunk)
	return [chunks_to_load,chunks_to_unload]

func player_position(position : Vector2) -> Array:
	var reletive_position = hlp.round_Vector2(position/16/chunk_size - Vector2(0.5,0.5))
	var start = reletive_position
	var chunks_to_load := [start]
	for dir in hlp.eight_directions:
		chunks_to_load.append(start+dir)
	return _manage_load(chunks_to_load)

##########################################################################################	


#Buildings
##########################################################################################
func place_building(position : Vector2,index : int) -> void:
	_open_loaded_chunk(hlp.floor_Vector2(position/chunk_size))
	if position in _rect_array(opened_chunk.pos,chunk_size):
		#exists statement
		if opened_chunk.get_building(position) != []:
			return
		# add building
		opened_chunk.placed_buildings.append([position,index])
		_close_loaded_chunk()
	else:
		print("error, building attempted to place in the wrong chunk")

func _rect_array(start : Vector2,size : int) -> Array:
	var output := []
	for x in range(size):
		for y in range(size):
			output.append(start + Vector2(x,y))
	return output

func remove_building(position : Vector2) -> void:
	_open_chunk(hlp.floor_Vector2(position/chunk_size))
	if position in _rect_array(opened_chunk.pos,chunk_size):
		for build in opened_chunk.placed_buildings:
			if build[0] == position:
				opened_chunk.placed_buildings.erase(build)
		_close_loaded_chunk()
	else:
		print("error, attempted to remove building in the wrong chunk")

##########################################################################################


#Chunk Generation
##########################################################################################
func _generate_chunk(position : Vector2):
	var values := []
	for x in range(chunk_size):
		for y in range(chunk_size):
			values.append(100)
	return values
##########################################################################################