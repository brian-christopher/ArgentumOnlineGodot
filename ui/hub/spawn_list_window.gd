extends AcceptDialog
class_name SpawnListWindow

@onready var creature_list: ItemList = $VBox/CreatureList
@onready var invoke_button: Button = $VBox/ButtonsContainer/InvokeButton

var _creatures: Array[String] = []

func _ready() -> void:
	# Configurar la ventana como no-exclusiva para permitir inputs globales
	exclusive = false
	# Permitir cerrar con la X de la ventana
	close_requested.connect(hide)
	title = "Entrenar Criatura"
	
	# Ocultar el botón OK por defecto
	get_ok_button().visible = false
	
	# Conectar señales
	invoke_button.pressed.connect(_on_invoke_button_pressed)
	creature_list.item_selected.connect(_on_creature_selected)
	
func set_creatures(creatures: Array[String]) -> void:
	_creatures = creatures
	creature_list.clear()
	
	for i in range(creatures.size()):
		creature_list.add_item(creatures[i])
	
	# Seleccionar el primer item si hay criaturas
	if creatures.size() > 0:
		creature_list.select(0)
		invoke_button.disabled = false
	else:
		invoke_button.disabled = true

func _on_creature_selected(_index: int) -> void:
	invoke_button.disabled = false

func _on_invoke_button_pressed() -> void:
	var selected_indices = creature_list.get_selected_items()
	if selected_indices.size() > 0:
		var selected_index = selected_indices[0]
		# El índice enviado al servidor es 1-indexed
		GameProtocol.WriteTrain(selected_index + 1)
		hide()
