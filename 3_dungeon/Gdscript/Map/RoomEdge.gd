# File: RoomEdge.gd
# 表示两个房间之间的边（潜在的走廊）
extends RefCounted
class_name RoomEdge

var room_a: Branch  # 第一个房间
var room_b: Branch  # 第二个房间
var weight: float   # 权重（距离）


func _init(a: Branch, b: Branch):
	"""初始化边，计算权重"""
	room_a = a
	room_b = b
	
	# 使用曼哈顿距离作为权重
	var center_a = room_a.get_center()
	var center_b = room_b.get_center()
	weight = abs(center_a.x - center_b.x) + abs(center_a.y - center_b.y)


func get_rooms() -> Array:
	"""返回边连接的两个房间"""
	return [room_a, room_b]


func _to_string() -> String:
	"""调试输出"""
	return "Edge(%s -> %s, weight=%.1f)" % [
		room_a.position,
		room_b.position,
		weight
	]
