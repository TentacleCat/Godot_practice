# File: CorridorGenerator.gd
# 使用 Kruskal 算法生成最优走廊连接
extends RefCounted
class_name CorridorGenerator


static func generate_corridors(rooms: Array) -> Array:
	"""
	使用 Kruskal 最小生成树算法生成走廊
	
	参数:
	- rooms: BSP 叶子节点数组（所有房间）
	
	返回:
	- 选中的边数组（RoomEdge），代表需要绘制的走廊
	"""
	
	if rooms.size() <= 1:
		return []  # 只有一个或没有房间，无需走廊
	
	# 步骤 1: 创建所有可能的边
	var all_edges: Array[RoomEdge] = []
	
	for i in range(rooms.size()):
		for j in range(i + 1, rooms.size()):
			var edge = RoomEdge.new(rooms[i], rooms[j])
			all_edges.append(edge)
	
	print("创建了 %d 条可能的边（从 %d 个房间）" % [all_edges.size(), rooms.size()])
	
	# 步骤 2: 按权重排序（距离从小到大）
	all_edges.sort_custom(func(a, b): return a.weight < b.weight)
	
	# 步骤 3: 初始化并查集
	var uf = UnionFind.new()
	for room in rooms:
		uf.make_set(room)
	
	# 步骤 4: Kruskal 算法 - 选择边
	var selected_edges: Array = []
	var edges_needed = rooms.size() - 1  # n 个节点需要 n-1 条边
	
	for edge in all_edges:
		if selected_edges.size() >= edges_needed:
			break  # 已经选够了
		
		var rooms_pair = edge.get_rooms()
		var room_a = rooms_pair[0]
		var room_b = rooms_pair[1]
		
		# 如果两个房间不在同一集合（连接它们不会形成环）
		if not uf.connected(room_a, room_b):
			selected_edges.append(edge)
			uf.union(room_a, room_b)
			print("  ✓ 添加走廊: %s -> %s (距离 %.1f)" % [
				room_a.position,
				room_b.position,
				edge.weight
			])
	
	print("Kruskal 完成：选择了 %d/%d 条边" % [selected_edges.size(), edges_needed])
	
	return selected_edges


static func draw_corridor(edge: RoomEdge, tilemap: TileMapLayer, source_id: int, atlas_coords: Vector2i) -> void:
	"""
	绘制 L 形走廊
	
	参数:
	- edge: 房间边
	- tilemap: TileMapLayer 节点
	- source_id: 瓦片源 ID
	- atlas_coords: 瓦片图集坐标
	"""
	
	var rooms = edge.get_rooms()
	var start = rooms[0].get_center()
	var end = rooms[1].get_center()
	
	# L 形走廊：先水平再垂直
	var corner = Vector2i(start.x, end.y)
	
	# 第一段：水平（从 start 到 corner）
	var x_min = min(start.x, corner.x)
	var x_max = max(start.x, corner.x)
	for x in range(x_min, x_max + 1):
		tilemap.set_cell(Vector2i(x, start.y), source_id, atlas_coords)
		# 加宽走廊（上下各一格）
		if start.y > 0:
			tilemap.set_cell(Vector2i(x, start.y - 1), source_id, atlas_coords)
		tilemap.set_cell(Vector2i(x, start.y + 1), source_id, atlas_coords)
	
	# 第二段：垂直（从 corner 到 end）
	var y_min = min(corner.y, end.y)
	var y_max = max(corner.y, end.y)
	for y in range(y_min, y_max + 1):
		tilemap.set_cell(Vector2i(corner.x, y), source_id, atlas_coords)
		# 加宽走廊（左右各一格）
		if corner.x > 0:
			tilemap.set_cell(Vector2i(corner.x - 1, y), source_id, atlas_coords)
		tilemap.set_cell(Vector2i(corner.x + 1, y), source_id, atlas_coords)
