extends Node2D

class_name GBubble

var size := 10.0
var color := Color.BLACK

var start_node: GNode
var end_node: GNode
var edge: Vector2
var velocity: float
var index: int

var is_on_path := false
var path: Array

func _init(vel: float = 300) -> void:
	velocity = vel
	z_index = -1

func _draw() -> void:
	draw_circle(Vector2.ZERO, size, color)

func _process(delta: float) -> void:
	if is_on_path:
		follow_path(delta)

func start_bubblin(bubble_path: Array):
	index = 0 
	path = bubble_path
	start_node = path[index]
	end_node = path[index + 1]
	edge = (start_node.position - end_node.position).normalized()
	
	start_node.deselect()
	
	position = start_node.position
	is_on_path = true

func follow_path(delta: float) -> void:
	if (position - end_node.position).length() <= 5:
		if index >= len(path) - 2:
			end_node.deselect()
			queue_free()
			return
		
		position = end_node.position
		index += 1
		start_node = path[index]
		start_node.deselect()
		end_node = path[index + 1]
		edge = (start_node.position - end_node.position).normalized()
	
	position -= edge * velocity * delta
