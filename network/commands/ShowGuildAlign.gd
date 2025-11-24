extends RefCounted
class_name ShowGuildAlign

# Referencia al nodo padre donde se agregará la ventana de alineación
var parent_node: Node

# Constructor
func _init(p_parent_node: Node = null):
	parent_node = p_parent_node

# Método estático para crear una instancia desde un StreamPeerBuffer
static func from_buffer(_stream: StreamPeerBuffer, p_parent_node: Node) -> ShowGuildAlign:
	var instance = ShowGuildAlign.new(p_parent_node)
	return instance

# Método para manejar la lógica cuando se recibe este paquete
func handle() -> void:
	# Verificar que tenemos un nodo padre válido
	if not parent_node or not is_instance_valid(parent_node):
		push_error("No se pudo mostrar la ventana de alineación: nodo padre no válido")
		return
		
	# Mostrar la ventana de selección de alineación
	_show_alignment_window()

# Muestra la ventana de selección de alineación
func _show_alignment_window() -> void:
	# Cargar la escena de la ventana de alineación
	var alignment_window_scene = preload("res://ui/hub/guild_alignment_window.tscn")
	var alignment_window = alignment_window_scene.instantiate()
	
	# Agregar la ventana al nodo padre
	parent_node.add_child(alignment_window)
	
	# Mostrar la ventana centrada
	alignment_window.popup_centered()
