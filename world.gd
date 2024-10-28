extends Node2D

var selected_node: GNode

var bfs_queue := []
var bfs_index = 0

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.is_pressed(): 
		if event.button_index == MOUSE_BUTTON_LEFT:
			edit_graph(event.position)
		
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			delete_node(get_node_from_position(event.position))
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and selected_node:
			var path = find_path(selected_node, get_node_from_position(event.position))
			
			if not path:
				selected_node.deselect()
				selected_node = null
				return
			
			for n in path:
				n.select(Color.YELLOW)
			
			var bubble = GBubble.new()
			add_child(bubble)
			bubble.start_bubblin(path)
			
			selected_node = null
	
	elif event is InputEventKey and event.is_pressed():
		
		if event.keycode == KEY_SPACE:
			select_neighbours(selected_node, Color.DARK_ORANGE)
		
		elif event.keycode == KEY_R:
			for child in get_children():
				if child is GNode:
					child.deselect()
			
			bfs_queue = []
			bfs_index = 0
		
		elif event.keycode == KEY_S:
			bfs_step()
		
		#elif event.keycode == KEY_B:
		#	make_bubble(selected_node, get_node_from_position(get_viewport().get_mouse_position()))
		
		if selected_node:
			selected_node.deselect()
			selected_node = null

func get_node_from_position(pos: Vector2) -> GNode:
	for child in get_children():
		if not child is GNode:
			continue
		
		if (child.position - pos).length() <= child.size:
			return child
		
	return null

func edit_graph(pos: Vector2) -> void:
	var node = get_node_from_position(pos)
	
	#Create node
	if not node:
		node = GNode.new()
		node.position = pos
		add_child(node)
		return
	
	#Select GNode
	if not selected_node:
		node.select()
		selected_node = node
		return
	
	if node == selected_node:
		node.deselect()
		selected_node = null
		return
	
	var edge = node.get_edge_to_node(selected_node)
	
	#Remove GEdge
	if edge:
		node.remove_edge(edge)
		selected_node.remove_edge(edge)
		edge.queue_free()
	
	#Create GEdge
	else:
		edge = GEdge.new(selected_node, node)
		selected_node.add_edge(edge)
		node.add_edge(edge)
		add_child(edge)
	
	selected_node.deselect()
	selected_node = null

func delete_node(node: GNode) -> void:
	if not node:
		return
	
	if selected_node == node:
		selected_node = null
	
	for e in node.edges:
		e.get_other_node(node).remove_edge(e)
		e.queue_free()
	
	node.edges = []
	node.queue_free()

func select_neighbours(node: GNode, color: Color) -> void:
	if not selected_node:
		return
	
	for n in node.get_neighbours():
		n.select(color)

func bfs_step() -> void:
	if bfs_queue:
		if bfs_index > (len(bfs_queue) - 1):
			for n in bfs_queue:
				n.select(Color.VIOLET)
			bfs_queue = []
			return
		
		var current_node: GNode = bfs_queue[bfs_index]
		
		for n in current_node.get_neighbours():
			if bfs_queue.find(n) < 0:
				bfs_queue.append(n)
				n.select(Color.BLUE_VIOLET)
		
		bfs_index += 1
	
	elif selected_node:
		bfs_index = 0
		bfs_queue.append(selected_node)
		selected_node.select(Color.BLUE_VIOLET)
		selected_node = null

func get_connected_graph() -> Array:
	var graph := []
	var thinking := true
	
	while thinking:
		if bfs_queue:
			if bfs_index > (len(bfs_queue) - 1):
				bfs_queue = []
				thinking = false
			
			var current_node: GNode = bfs_queue[bfs_index]
			
			for n in current_node.get_neighbours():
				if bfs_queue.find(n) < 0:
					bfs_queue.append(n)
					graph.append(n)
			
			bfs_index += 1
		
		elif selected_node:
			bfs_index = 0
			bfs_queue.append(selected_node)
			graph.append(selected_node)
			selected_node = null
	
	return graph


func get_all_nodes() -> Array:
	var nodes := []
	for child in get_children():
		if child is GNode:
			nodes.append(child)
	return nodes

func get_min_distance(nodes: Array, dists: Dictionary) -> GNode:
	var min_dist := 5000000000;
	var result: GNode
	
	for n in nodes:
		if dists.has(n) and dists[n] < min_dist:
			min_dist = dists[n]
			result = n
	
	return result

func find_path(start_node: GNode, end_node: GNode) -> Array:
	if not (start_node and end_node):
		return []
	
	var path := []
	var queue := get_connected_graph()
	var distances := {}
	distances[start_node] = 0
	var ancestors := {}
	
	while queue:
		var v = get_min_distance(queue, distances)
		queue.erase(v)
		
		for k in v.edges:
			var u = k.get_other_node(v)
			var new_dist: float = distances[v] + k.get_lenght()
			
			if not distances.has(u) or new_dist < distances[u]:
				distances[u] = new_dist
				ancestors[u] = v
		
	var node: GNode = end_node
	
	while node != start_node:
		path.append(node)
		node = ancestors[node]
	
	path.append(start_node)
	
	path.reverse()
		
	return path

#func make_bubble(n1: GNode, n2: GNode) -> void:
#	if not (n1 and n2):
#		return
#	
#	if not n1.get_edge_to_node(n2):
#		return
#	
#	var bubble = GBubble.new(n1, n2)
#	
#	add_child(bubble)
