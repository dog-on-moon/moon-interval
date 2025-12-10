@tool
extends GraphEdit
class_name GraphEdit2

static var undo_redo: Object

var _resource_ref: WeakRef

## Sets the resource for the GraphEdit.
@export var resource: GraphEditResource:
	set(x):
		if resource:
			resource.editor_refresh.disconnect(_refresh)
		_resource_ref = weakref(x)
		selected_elements = []
		if resource:
			resource.editor_refresh.connect(_refresh)
		if is_node_ready():
			_validate_connections()
			_refresh()
			recenter()
			recenter()
	get:
		return _resource_ref.get_ref() if _resource_ref else null

var resource_to_element := {}
var active_elements: Array[GraphElement] = []
var selected_elements: Array[GraphElement] = []

var element_clipboard := {}
var connection_clipboard := []
var clipboard_pos := Vector2.ZERO

var popup_menu: GraphEdit2PopupMenu

var mouse_inside: bool:
	get:
		return get_global_rect().has_point(get_global_mouse_position())

func _ready() -> void:
	## GraphEdit signals
	connection_request.connect(_connection_request)
	connection_from_empty.connect(_connection_from_empty)
	connection_to_empty.connect(_connection_to_empty)
	disconnection_request.connect(_disconnection_request)
	copy_nodes_request.connect(_copy_nodes_request)
	paste_nodes_request.connect(func (): _paste_nodes_request(clipboard_pos))
	delete_nodes_request.connect(_delete_nodes_request)
	duplicate_nodes_request.connect(_duplicate_nodes_request)
	end_node_move.connect(_end_node_move)
	node_selected.connect(_node_selected)
	node_deselected.connect(_node_deselected)
	popup_request.connect(_popup_request)
	
	## Create popup menu
	popup_menu = _get_popup_menu_class().new()
	add_child(popup_menu)
	popup_menu.hide()
	
	## Popup menu signals
	popup_menu.request_create_resource.connect(add_resource)
	popup_menu.request_paste_resources.connect(func (x): _paste_nodes_request(x))

func _process(delta: float) -> void:
	_validate_connections()

#region GraphEdit Signals
func _connection_request(from_node_name: StringName, from_port: int, to_node_name: StringName, to_port: int):
	assert(resource)
	var from_node: GraphNode2 = get_node(NodePath(from_node_name))
	var to_node: GraphNode2 = get_node(NodePath(to_node_name))
	undo_redo.create_action("Connect GraphNodes")
	undo_redo.add_do_method  (resource, &"connect_resources",    from_node.resource, from_port, to_node.resource, to_port)
	undo_redo.add_undo_method(resource, &"disconnect_resources", from_node.resource, from_port, to_node.resource, to_port)
	undo_redo.commit_action()

func _connection_from_empty(to_node: StringName, to_port: int, release_position: Vector2):
	assert(resource)
	var pos := (release_position + scroll_offset) / zoom
	var resource: Resource = get_node(NodePath(to_node)).resource
	popup_menu.activate(pos, resource, to_port, true)

func _connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2):
	assert(resource)
	var pos := (release_position + scroll_offset) / zoom
	var resource: Resource = get_node(NodePath(from_node)).resource
	popup_menu.activate(pos, resource, from_port, false)

func _disconnection_request(from_node_name: StringName, from_port: int, to_node_name: StringName, to_port: int):
	assert(resource)
	var from_node: GraphNode2 = get_node(NodePath(from_node_name))
	var to_node: GraphNode2 = get_node(NodePath(to_node_name))
	undo_redo.create_action("Disconnect GraphNodes")
	undo_redo.add_do_method  (resource, &"disconnect_resources", from_node.resource, from_port, to_node.resource, to_port)
	undo_redo.add_undo_method(resource, &"connect_resources",    from_node.resource, from_port, to_node.resource, to_port)
	undo_redo.commit_action()

func _copy_nodes_request():
	## Create a clone for each resource.
	element_clipboard = {}
	connection_clipboard = []
	var res_to_copy = {}
	for node in selected_elements:
		if node.resource.graph_can_be_copied():
			res_to_copy[node.resource] = node.resource.duplicate_deep(Resource.DEEP_DUPLICATE_NONE)
	
	## Determine the connections to be copied.
	for c in resource.connections:
		if c[0] in res_to_copy and c[2] in res_to_copy:
			connection_clipboard.append([
				res_to_copy[c[0]],
				c[1],
				res_to_copy[c[2]],
				c[3]
			])
	
	## Determine the root position for our copy.
	var top_left := Vector2(999999, 999999)
	for node in selected_elements:
		if node.resource in res_to_copy:
			top_left.x = min(top_left.x, node.position_offset.x)
			top_left.y = min(top_left.y, node.position_offset.y)
	
	## Create copies of each resource.
	for node in selected_elements:
		if node.resource in res_to_copy:
			element_clipboard[res_to_copy[node.resource]] = node.position_offset - top_left
	clipboard_pos = top_left

func _paste_nodes_request(top_left_paste_pos: Vector2):
	assert(resource)
	## Remove our selection.
	for node in selected_elements.duplicate():
		node.set_selected(false)
	
	## Clone all resources.
	for resource in element_clipboard:
		add_resource(resource, element_clipboard[resource] + top_left_paste_pos)
		resource_to_element[resource].set_selected(true)
	
	## Clone all connections.
	for c in connection_clipboard:
		resource.connect_resources(c[0], c[1], c[2], c[3])
	
	## Create new clipboard.
	var new_clipboard := {}
	for resource in element_clipboard:
		var new_res = resource.duplicate_deep(Resource.DEEP_DUPLICATE_NONE)
		new_clipboard[new_res] = element_clipboard[resource]
		for c in connection_clipboard:
			if c[0] == resource:
				c[0] = new_res
			if c[2] == resource:
				c[2] = new_res
	element_clipboard = new_clipboard

func _delete_nodes_request(nodes: Array[StringName]):
	assert(resource)
	for node_name in nodes:
		var node: Node = get_node(NodePath(node_name))
		if node is GraphElement:
			remove_resource(node.resource)

func _duplicate_nodes_request():
	assert(resource)
	for node in selected_elements.duplicate():
		var res: Resource = node.resource
		var idx: int = resource.resources.find(res)
		var res_dupe := res.duplicate_deep(Resource.DEEP_DUPLICATE_NONE)
		add_resource(res_dupe, node.position_offset)
		node.set_selected(false)
		resource_to_element[res_dupe].set_selected(true)

func _end_node_move():
	assert(resource)
	for node in active_elements:
		var node_pos: Vector2 = resource.get_resource_position(node.resource)
		var target_pos := node.position_offset + scroll_offset
		resource.move_resource(node.resource, target_pos)
		# TODO - this undo is super broken and idk why
		#undo_redo.create_action("%s move event %s" % [multi_event.to_string(), get_tree().get_frame()], UndoRedo.MERGE_ALL)
		#undo_redo.add_do_method(multi_event, &"set_event_editor_position", node.event, target_pos)
		#undo_redo.add_undo_method(self, &"_move_node", node, node_pos, node.position_offset)
		#undo_redo.commit_action()

func _node_selected(node: Node):
	assert(resource)
	if node is GraphElement:
		selected_elements.append(node)

func _node_deselected(node: Node):
	assert(resource)
	if node is GraphElement:
		selected_elements.erase(node)

func _popup_request(at_position: Vector2):
	assert(resource)
	popup_menu.activate((at_position + scroll_offset) / zoom)
#endregion

#region Editor interface
## Adds a Resource into the GraphEdit.
func add_resource(resource: Resource, position: Vector2):
	assert(self.resource)
	undo_redo.create_action("New GraphElement(s) %s" % [get_tree().get_frame()], UndoRedo.MERGE_ALL)
	undo_redo.add_do_method(self.resource, &"add_resource", resource, position)
	undo_redo.add_undo_method(self.resource, &"remove_resource", resource)
	undo_redo.commit_action()

## Removes a Resource from the GraphEdit.
func remove_resource(resource: Resource):
	assert(self.resource)
	undo_redo.create_action("Delete GraphElement(s) %s" % [get_tree().get_frame()], UndoRedo.MERGE_ALL)
	undo_redo.add_do_method(self.resource, &"remove_resource", resource)
	undo_redo.add_undo_method(self.resource, &"add_resource", resource, self.resource.get_resource_position(resource))
	undo_redo.commit_action()

## Refreshes the state of the GraphEdit.
func _refresh():
	if not resource:
		## Cleanup.
		clear_connections()
		for element in active_elements.duplicate():
			element.queue_free()
		resource_to_element = {}
		active_elements = []
	else:
		## Delete un-accounted for nodes.
		var existing_resources := {}
		for element in active_elements.duplicate():
			if not is_instance_valid(element) or element.resource not in resource.resources:
				selected_elements.erase(element)
				active_elements.erase(element)
				element.queue_free()
			else:
				existing_resources[element.resource] = null
		
		## Create missing nodes.
		for res in resource.resources:
			if res not in existing_resources:
				var element: Control = res._make_graph_control()
				resource_to_element[res] = element
				active_elements.append(element)
				add_child(element)
				element.resource = res
				element.position_offset = resource.get_resource_position(res)
		
		## Rebuild connections.
		## Dictionary[Resource, Dict[int, Array[Resource]]]
		clear_connections()
		for c in resource.connections:
			var from_node: GraphNode2 = resource_to_element[c[0]]
			var to_node: GraphNode2 = resource_to_element[c[2]]
			connect_node(from_node.name, c[1], to_node.name, c[3])

## Validates all of the connections in the GraphNode.
func _validate_connections():
	if not resource:
		return
	
	## Validate the connections for each GraphNode.
	for c: Array in resource.connections.duplicate():
		var from_resource: GraphNodeResource = c[0]
		var from_port: int = c[1]
		var to_resource: GraphNodeResource = c[2]
		var to_port: int = c[3]
		
		if from_port >= from_resource.get_output_connections() or to_port >= to_resource.get_input_connections():
			resource.disconnect_resources(from_resource, from_port, to_resource, to_port)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cut") and selected_elements:
		_copy_nodes_request()
		for node in selected_elements.duplicate():
			remove_resource(node.resource)
		accept_event()
	if event.is_action_pressed("ui_text_select_all") and mouse_inside:
		for node in active_elements:
			if node not in selected_elements:
				node.set_selected(true)
		accept_event()
	if event is InputEventMouseButton:
		if event.pressed and event.button_index  == MOUSE_BUTTON_LEFT:
			# If we've pressed somewhere not within the grid,
			# guarantee that we deselect all of our internal nodes
			if selected_elements and not mouse_inside:
				for node in selected_elements.duplicate():
					node.set_selected(false)

## Recenters the GraphEdit.
func recenter():
	zoom = 1.0
	await get_tree().process_frame
	if not active_elements:
		scroll_offset = Vector2.ZERO
		return
	var average_node_position := Vector2.ZERO
	for node in active_elements:
		average_node_position += node.position_offset + (node.size / 2)
	average_node_position /= active_elements.size()
	for node in active_elements:
		node.position_offset -= average_node_position
	scroll_offset = - (size / 2)
#endregion

#region Editor overrides
## Returns an array of all element resource classes that can be created in this GraphEdit.
static func get_element_resource_classes() -> Array:
	## see load_scripts_of_base_class()
	return [GraphElementResource, GraphFrameResource, GraphNodeResource]

## Gets the popup menu class used for 
static func _get_popup_menu_class() -> Script:
	return GraphEdit2PopupMenu
#endregion

#region Helpers
## Helper function to nab all scripts of a given base class
static func load_scripts_of_base_class(base_class: StringName) -> Array:
	var global_class_list := ProjectSettings.get_global_class_list()
	var ret_dict := {}
	var last_result := -1
	while last_result != ret_dict.size():
		last_result = ret_dict.size()
		for item in global_class_list:
			if item['base'] in ret_dict or item['class'] == base_class:
				ret_dict[item['class']] = load(item['path'])
	return ret_dict.values()
#endregion
