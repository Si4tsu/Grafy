extends Node2D

class_name  GEdge

var node1: GNode
var node2: GNode

func _init(n1: GNode, n2: GNode):
	node1 = n1
	node2 = n2
	z_index = -2

func _draw() -> void:
	draw_line(node1.position, node2.position, Color.BLACK, 2, true)

func has(node) -> bool:
	return node1 == node or node2 == node

func get_other_node(node: GNode) -> GNode:
	var other_node: GNode
	
	if node == node1:
		other_node = node2
	
	elif node == node2:
		other_node = node1
	
	return other_node

func get_lenght() -> float:
	if node1 and node2:
		return (node1.position - node2.position).length()
	
	return -1.0
