extends Node
@export var cell_scene : PackedScene
var row_count : int = 45
var column_count : int = 80
var cell_width : int = 15 

var cell_matrix : Array = []
var pre_cell_states : Array = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	for column in range(column_count):
		cell_matrix.push_back([])
		pre_cell_states.push_back([])
		for row in range(row_count):
			var cell = cell_scene.instantiate()
			self.add_child(cell)
			cell.position = Vector2(column*cell_width, row*cell_width)
			if rng.randi_range(0,1) or is_edge(column, row):
				cell.visible = false
				pre_cell_states[column].push_back(false)
			else:
			#print(column, ",", row)
				pre_cell_states[column].push_back(true)
			cell_matrix[column].push_back(cell)
	print(pre_cell_states)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for column in range(column_count):
		for row in range(row_count):
			pre_cell_states[column][row] = cell_matrix[column][row].visible
	for column in range(column_count):
		for row in range(row_count):
			if !is_edge(column, row):
				cell_matrix[column][row].visible = get_next_state(column, row)
	pass
	
func get_next_state(column, row):
	var current = pre_cell_states[column][row]
	var neighbours_alive = get_count_of_alive_neighbours(column, row)
	#death
	if current:
		if neighbours_alive > 3:
			return false
		elif neighbours_alive < 2:
			return false
	#birth
	else:
		if neighbours_alive == 3:
			return true
	#stasis
	return current
	
func is_edge(column, row):
	return row == 0 or column == 0 or row == row_count -1 or column == column_count -1
	
func get_count_of_alive_neighbours(column, row):
	var count = 0
	for x in range(-1,2):
		for y in range(-1, 2):
			if not (x == 0 and y == 0):
				if pre_cell_states[column+x][row+y]:
					count += 1
	return count
