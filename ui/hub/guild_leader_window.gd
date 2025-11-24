extends Window
class_name GuildLeaderWindow

## Ventana de administración del clan para líderes
## Replica la funcionalidad de frmGuildLeader.frm del cliente VB6

const MAX_NEWS_LENGTH = 512

# Referencias a nodos
@onready var guilds_list: ItemList = $ScrollContainer/VBox/TopListsContainer/LeftPanel/GuildsList
@onready var members_list: ItemList = $ScrollContainer/VBox/TopListsContainer/RightPanel/MembersList
@onready var requests_list: ItemList = $ScrollContainer/VBox/MiddleSection/LeftColumn/RequestsList
@onready var news_text: TextEdit = $ScrollContainer/VBox/VBoxContainer/NewsText
@onready var filter_guilds: LineEdit = $ScrollContainer/VBox/TopListsContainer/LeftPanel/FilterPanel/FilterGuilds
@onready var filter_members: LineEdit = $ScrollContainer/VBox/TopListsContainer/RightPanel/FilterPanel/FilterMembers
@onready var members_count_label: Label = $ScrollContainer/VBox/BottomSection/MembersCountLabel

# NO guardamos datos - todo viene del servidor en tiempo real

func _ready() -> void:
	close_requested.connect(_on_close_requested)
	news_text.text_changed.connect(_on_news_text_changed)
	
	# Forzar modo ventana flotante (no embed)
	popup_window = true

func _on_close_requested() -> void:
	hide()

## Muestra los datos del clan recibidos del servidor (sin guardarlos)
func set_guild_data(guilds: Array, members: Array, news: String, requests: Array) -> void:
	# Limpiar y mostrar clanes
	guilds_list.clear()
	for guild_name in guilds:
		guilds_list.add_item(guild_name)
	
	# Limpiar y mostrar miembros
	members_list.clear()
	for member_name in members:
		members_list.add_item(member_name)
	
	# Limpiar y mostrar solicitudes
	requests_list.clear()
	for request_name in requests:
		requests_list.add_item(request_name)
	
	# Mostrar noticias (convertir separador º a saltos de línea)
	news_text.text = news.replace("º", "\n")
	
	# Actualizar contador
	members_count_label.text = "El clan cuenta con %d MIEMBROS" % members.size()

# Filtros deshabilitados - solicitar datos al servidor cuando se necesiten
func _on_filter_guilds_text_changed(_new_text: String) -> void:
	pass  # TODO: Solicitar datos filtrados al servidor

func _on_filter_members_text_changed(_new_text: String) -> void:
	pass  # TODO: Solicitar datos filtrados al servidor

func _on_guilds_list_item_selected(_index: int) -> void:
	pass

func _on_members_list_item_selected(_index: int) -> void:
	pass

func _on_guild_details_btn_pressed() -> void:
	var selected_items = guilds_list.get_selected_items()
	if selected_items.size() == 0:
		return
	
	var selected_index = selected_items[0]
	var guild_name = guilds_list.get_item_text(selected_index)
	GameProtocol.WriteGuildRequestDetails(guild_name)

func _on_member_details_btn_pressed() -> void:
	var selected_items = members_list.get_selected_items()
	if selected_items.size() == 0:
		return
	
	var selected_index = selected_items[0]
	var member_name = members_list.get_item_text(selected_index)
	GameProtocol.WriteGuildMemberInfo(member_name)

func _on_request_details_btn_pressed() -> void:
	var selected_items = requests_list.get_selected_items()
	if selected_items.size() == 0:
		return
	
	var selected_index = selected_items[0]
	var request_name = requests_list.get_item_text(selected_index)
	GameProtocol.WriteGuildMemberInfo(request_name)

func _on_update_news_btn_pressed() -> void:
	# Reemplazar saltos de línea con el separador especial (como en VB6)
	var news = news_text.text.replace("\n", "º")
	GameProtocol.WriteGuildUpdateNews(news)

func _on_edit_codex_btn_pressed() -> void:
	# Abrir ventana de edición de códex
	var guild_details_window = load("res://ui/hub/guild_details_window.tscn").instantiate()
	get_parent().add_child(guild_details_window)
	guild_details_window.popup_centered()

func _on_edit_url_btn_pressed() -> void:
	# Abrir ventana de edición de URL
	var guild_url_window = load("res://ui/hub/guild_url_window.tscn").instantiate()
	get_parent().add_child(guild_url_window)
	guild_url_window.popup_centered()

func _on_peace_proposals_btn_pressed() -> void:
	# Solicitar lista de propuestas de paz
	GameProtocol.WriteGuildPeacePropList()

func _on_alliance_proposals_btn_pressed() -> void:
	# Solicitar lista de propuestas de alianza
	GameProtocol.WriteGuildAlliancePropList()

func _on_elections_btn_pressed() -> void:
	# Mostrar menú de opciones de elecciones
	var menu_dialog = ConfirmationDialog.new()
	menu_dialog.title = "Gestión de Elecciones"
	menu_dialog.dialog_text = "¿Qué deseas hacer?"
	menu_dialog.ok_button_text = "Abrir Elecciones"
	menu_dialog.cancel_button_text = "Votar"
	
	# Si se confirma, abrir elecciones (solo líderes)
	menu_dialog.confirmed.connect(func():
		var confirm_dialog = ConfirmationDialog.new()
		confirm_dialog.dialog_text = "¿Estás seguro de que deseas abrir elecciones en el clan?\n\nEsto permitirá que todos los miembros voten por un nuevo líder."
		confirm_dialog.title = "Confirmar Apertura de Elecciones"
		confirm_dialog.confirmed.connect(func():
			GameProtocol.WriteGuildOpenElections()
			hide()
		)
		add_child(confirm_dialog)
		confirm_dialog.popup_centered()
	)
	
	# Si se cancela, abrir ventana de votación
	menu_dialog.canceled.connect(func():
		_open_vote_window()
	)
	
	add_child(menu_dialog)
	menu_dialog.popup_centered()

## Abre la ventana de votación
func _open_vote_window() -> void:
	var vote_window = load("res://ui/hub/guild_vote_window.tscn").instantiate()
	get_parent().add_child(vote_window)
	# Los miembros se solicitan al servidor cuando se abre la ventana
	vote_window.popup_centered()

func _on_close_btn_pressed() -> void:
	hide()

func _on_news_text_changed() -> void:
	# Limitar longitud de las noticias
	if news_text.text.length() > MAX_NEWS_LENGTH:
		news_text.text = news_text.text.substr(0, MAX_NEWS_LENGTH)
		news_text.set_caret_column(MAX_NEWS_LENGTH)
