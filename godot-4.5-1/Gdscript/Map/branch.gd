extends Node

class_name Branch

var left_child:  Branch
var right_child:  Branch
var position: Vector2i
var size: Vector2i

func _init(starting_position, starting_size):
	self.position = starting_position #左上角
	self.size = starting_size

func split(remaining: int, paths: Array, max_aspect_ratio: float = 2.5, min_cell_size: int = 8):
	"""
	递归分割节点
	参数:
	- remaining: 剩余分割次数
	- paths: 路径数组
	- max_aspect_ratio: 最大宽高比（防止细长房间）
	- min_cell_size: 最小单元格尺寸（终止条件）
	"""
	
	# 1. 终止条件：尺寸太小或分割次数用完
	if size.x < min_cell_size * 2 or size.y < min_cell_size * 2 or remaining <= 0:
		return
	
	var rng = RandomNumberGenerator.new()
	var split_percent = rng.randf_range(0.3, 0.7)
	
	# 2. 宽高比检查：决定分割方向（强制修正细长形状）
	var ratio = float(size.x) / float(size.y)
	var is_too_wide = ratio > max_aspect_ratio
	var is_too_tall = (1.0 / ratio) > max_aspect_ratio
	
	var split_horizontal: bool
	
	if is_too_wide:
		# 房间太宽，强制垂直分割（切开宽度）
		split_horizontal = false
	elif is_too_tall:
		# 房间太高，强制水平分割（切开高度）
		split_horizontal = true
	else:
		# 形状良好，切开更长的边
		split_horizontal = size.y >= size.x
	
	# 3. 执行分割并保证子区域尺寸
	if split_horizontal:
		var left_height = int(size.y * split_percent)
		
		# 确保分割后的区域不会太小
		left_height = max(min_cell_size, left_height)
		left_height = min(size.y - min_cell_size, left_height)
		
		# 安全检查
		if left_height <= 0 or size.y - left_height <= 0:
			return
		
		left_child = Branch.new(position, Vector2i(size.x, left_height))
		right_child = Branch.new(
			Vector2i(position.x, position.y + left_height), 
			Vector2i(size.x, size.y - left_height)
		)
	else:
		var left_width = int(size.x * split_percent)
		
		# 确保分割后的区域不会太小
		left_width = max(min_cell_size, left_width)
		left_width = min(size.x - min_cell_size, left_width)
		
		# 安全检查
		if left_width <= 0 or size.x - left_width <= 0:
			return
		
		left_child = Branch.new(position, Vector2i(left_width, size.y))
		right_child = Branch.new(
			Vector2i(position.x + left_width, position.y), 
			Vector2i(size.x - left_width, size.y)
		)
	
	# 4. 递归分割（传递参数）
	if remaining > 0:
		left_child.split(remaining - 1, paths, max_aspect_ratio, min_cell_size)
		right_child.split(remaining - 1, paths, max_aspect_ratio, min_cell_size)
		
	pass
	
func get_leaves():
	if not (left_child && right_child):
		return [self]
	else:
		return left_child.get_leaves() + right_child.get_leaves()
		
func get_center():
	return Vector2i(position.x + size.x / 2, position.y + size.y / 2)
