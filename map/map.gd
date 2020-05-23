extends TileMap


const chunks_update_time = 0.5
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	ChunkLoader.set_path("res://save/".plus_file("world1"))
	ChunkLoader.set_path("res://save/".plus_file("world1").plus_file("chunks"))
	var chunk_timer = Timer.new()
	add_child(chunk_timer)
	chunk_timer.wait_time = chunks_update_time
	chunk_timer.connect("timeout",self,"_on_chunk_update")
	chunk_timer.start()


func _on_chunk_update():
	var data = ChunkLoader.player_position($demo_player.position)
	for chunk in data[0]:
		for point in chunk.get_points():
			set_cellv(point[0],point[1])
	for chunk in data[1]:
		for point in chunk.get_points():
			set_cellv(point[0],-1)