extends Window
class_name GuildMemberWindow

## Ventana de información del clan para miembros no líderes
## Replica la funcionalidad de frmGuildMember.frm del cliente VB6

@onready var guilds_list: ItemList = $VBox/MainContent/LeftPanel/GuildsList
@onready var members_list: ItemList = $VBox/MainContent/RightPanel/MembersList
@onready var search_guilds: LineEdit = $VBox/MainContent/LeftPanel/SearchGuilds
@onready var search_members: LineEdit = $VBox/MainContent/RightPanel/SearchMembers
@onready var members_label: Label = $VBox/MainContent/RightPanel/MembersLabel

# NO guardamos datos - todo viene del servidor en tiempo real


func _on_close_requested() -> void:
	hide()

## Muestra los datos del clan recibidos del servidor (sin guardarlos)
func set_guild_data(guilds: Array, members: Array) -> void:
	# Mostrar clanes
	guilds_list.clear()
	for guild_name in guilds:
		guilds_list.add_item(guild_name)
	
	# Mostrar miembros
	for member_name in members:
		members_list.add_item(member_name)
	
	members_label.text = "Miembros (" + str(members.size()) + ")"

func _on_search_guilds_text_changed(_new_text: String) -> void:
	pass  # Filtrado deshabilitado - solicitar al servidor si es necesario

func _on_search_members_text_changed(_new_text: String) -> void:
	pass  # Filtrado deshabilitado - solicitar al servidor si es necesario

func _on_guilds_list_item_selected(_index: int) -> void:
	pass

func _on_members_list_item_selected(_index: int) -> void:
	pass

func _on_details_btn_pressed() -> void:
	var selected_items = guilds_list.get_selected_items()
	if selected_items.size() == 0:
		return
	
	var selected_index = selected_items[0]
	var guild_name = guilds_list.get_item_text(selected_index)
	GameProtocol.WriteGuildRequestDetails(guild_name)

func _on_news_btn_pressed() -> void:
	# Solicitar noticias del clan
	GameProtocol.WriteShowGuildNews()
	hide()
