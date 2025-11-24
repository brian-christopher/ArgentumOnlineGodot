extends Window
class_name GuildAdminWindow

## Ventana de lista de clanes para jugadores sin clan
## Replica la funcionalidad de frmGuildAdm.frm del cliente VB6

@onready var guilds_list: ItemList = $VBox/GuildsList
@onready var search_edit: LineEdit = $VBox/SearchEdit

# NO guardamos datos - todo viene del servidor en tiempo real

func _ready() -> void:
	close_requested.connect(_on_close_requested)

func _on_close_requested() -> void:
	hide()

## Muestra la lista de clanes recibida del servidor (sin guardarla)
func set_guilds(guilds: Array) -> void:
	guilds_list.clear()
	for guild_name in guilds:
		if !guild_name.is_empty():
			guilds_list.add_item(guild_name)

func _on_search_edit_text_changed(_new_text: String) -> void:
	pass  # Filtrado deshabilitado - solicitar al servidor si es necesario

func _on_guilds_list_item_selected(_index: int) -> void:
	pass

func _on_details_btn_pressed() -> void:
	var selected_items = guilds_list.get_selected_items()
	if selected_items.size() == 0:
		return
	
	var selected_index = selected_items[0]
	var guild_name = guilds_list.get_item_text(selected_index)
	GameProtocol.WriteGuildRequestDetails(guild_name)

func _on_close_btn_pressed() -> void:
	hide()
