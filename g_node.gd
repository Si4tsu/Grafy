extends Node2D

class_name GNode

@export var size: float = 20.0

var is_selected := false
var selection_color: Color
var edges = []


func _draw() -> void:
	if is_selected:
		draw_circle(Vector2.ZERO, size, selection_color)
	
	else:
		draw_circle(Vector2.ZERO, size, Color.CRIMSON)
	
	draw_circle(Vector2.ZERO, size, Color.BLACK, false, 2)

func select(color: Color = Color.GREEN) -> void:
	is_selected = true
	selection_color = color
	queue_redraw()

func deselect() -> void:
	is_selected = false
	queue_redraw()

func add_edge(e: GEdge) -> void:
	edges.append(e)

func remove_edge(e: GEdge) -> void:
	var i = edges.find(e)
	
	if i >= 0:
		edges.remove_at(i) 

func get_edge_to_node(node: GNode) -> GEdge:
	for e in edges:
		if e.has(node):
			return e
	
	return null

func get_neighbours() -> Array:
	var neighbours := []
	
	for e in edges:
		neighbours.append(e.get_other_node(self))
	
	return neighbours
