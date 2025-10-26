extends Node2D

# === 可导出参数（在 Inspector 中可调节）===
@export_group("World Settings")
@export var world_size: Vector2i = Vector2i(120, 60)  ## 地图尺寸（格子数）
@export_range(8, 32, 1) var tile_size: int = 16  ## 每个瓦片的像素大小

@export_group("BSP Settings")
@export_range(1, 6, 1) var split_iterations: int = 4  ## BSP 分割次数（影响房间数量）
@export_range(1.0, 4.0, 0.1) var max_aspect_ratio: float = 1.0  ## 最大宽高比（防止细长房间）
@export_range(4, 20, 1) var min_cell_size: int = 8  ## 最小单元格尺寸（分割终止条件）

@export_group("Room Settings")
@export_range(1, 5, 1) var min_padding: int = 2  ## 房间最小墙壁厚度
@export_range(1, 5, 1) var max_padding: int = 3  ## 房间最大墙壁厚度

# === 内部变量 ===
var root_node: Branch
var tilemap: TileMapLayer
var paths: Array = []


func _ready():
	# Godot 4.x 使用 TileMapLayer
	tilemap = get_node("TileMapLayer")
	
	generate_dungeon()


func generate_dungeon():
	"""生成地牢（可以在运行时调用来重新生成）"""
	# 清空之前的数据
	paths.clear()
	if tilemap:
		tilemap.clear()
	
	# 创建新的 BSP 树（传递参数）
	root_node = Branch.new(Vector2i(0, 0), world_size)
	root_node.split(split_iterations, paths, max_aspect_ratio, min_cell_size)
	
	# ✅ 在这里绘制房间和走廊到 TileMap
	render_dungeon()
	
	# 请求重绘调试图形
	queue_redraw()


func render_dungeon():
	"""渲染地牢到 TileMap"""
	var rng = RandomNumberGenerator.new()
	
	# 绘制房间
	for leaf in root_node.get_leaves():
		var padding = Vector4i(
			rng.randi_range(min_padding, max_padding),
			rng.randi_range(min_padding, max_padding),
			rng.randi_range(min_padding, max_padding),
			rng.randi_range(min_padding, max_padding)
		)
		
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				if not is_inside_padding(x, y, leaf, padding):
					tilemap.set_cell(
						Vector2i(x + leaf.position.x, y + leaf.position.y),  # coords
						0,                                                    # source_id
						Vector2i(2, 2)                                        # atlas_coords
					)
	
	# 绘制走廊
	for path in paths:
		if path['left'].y == path['right'].y:
			# 水平走廊
			for i in range(path['right'].x - path['left'].x):
				tilemap.set_cell(
					Vector2i(path['left'].x + i, path['left'].y),
					0,
					Vector2i(2, 2)
				)
		else:
			# 垂直走廊
			for i in range(path['right'].y - path['left'].y):
				tilemap.set_cell(
					Vector2i(path['left'].x, path['left'].y + i),
					0,
					Vector2i(2, 2)
				)


func _draw():
	"""绘制调试信息（BSP 分割的绿色边框）"""
	if root_node == null:
		return
	
	# 绘制所有叶子节点的边框
	for leaf in root_node.get_leaves():
		draw_rect(
			Rect2(
				leaf.position.x * tile_size,
				leaf.position.y * tile_size,
				leaf.size.x * tile_size,
				leaf.size.y * tile_size
			),
			Color.GREEN,
			false,  # 不填充，只画边框
			2.0     # 线条宽度
		) 


func is_inside_padding(x, y, leaf, padding):
	return x <= padding.x or y <= padding.y or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w
