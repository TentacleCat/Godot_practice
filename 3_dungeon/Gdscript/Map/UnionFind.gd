# File: UnionFind.gd
# 并查集数据结构（用于 Kruskal 算法）
extends RefCounted
class_name UnionFind

var parent: Dictionary = {}  # 父节点映射
var rank: Dictionary = {}    # 秩（树的高度）


func make_set(item) -> void:
	"""创建一个新的集合（初始化节点）"""
	parent[item] = item  # 自己是自己的父节点
	rank[item] = 0       # 初始秩为 0


func find(item):
	"""查找节点所属的集合（根节点）+ 路径压缩"""
	if parent[item] != item:
		# 路径压缩：递归查找根节点，并直接连接到根
		parent[item] = find(parent[item])
	return parent[item]


func union(item1, item2) -> void:
	"""合并两个节点所属的集合"""
	var root1 = find(item1)
	var root2 = find(item2)
	
	if root1 == root2:
		return  # 已经在同一集合中
	
	# 按秩合并：将秩小的树连接到秩大的树下
	if rank[root1] < rank[root2]:
		parent[root1] = root2
	elif rank[root1] > rank[root2]:
		parent[root2] = root1
	else:
		# 秩相同，随意选一个作为父节点，秩+1
		parent[root2] = root1
		rank[root1] += 1


func connected(item1, item2) -> bool:
	"""检查两个节点是否在同一集合中"""
	return find(item1) == find(item2)


func get_set_count() -> int:
	"""返回当前的集合数量"""
	var roots = {}
	for item in parent.keys():
		roots[find(item)] = true
	return roots.size()
