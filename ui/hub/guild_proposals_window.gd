extends Window
class_name GuildProposalsWindow

## Ventana de propuestas de paz/alianza
## Replica la funcionalidad de frmPeaceProp.frm del cliente VB6

enum ProposalType {
	PEACE = 1,
	ALLIANCE = 2
}

@onready var proposals_list: ItemList = $VBox/ProposalsList
@onready var selected_label: Label = $VBox/SelectedLabel
@onready var details_btn: Button = $VBox/ButtonsContainer/DetailsBtn
@onready var accept_btn: Button = $VBox/ButtonsContainer/AcceptBtn
@onready var reject_btn: Button = $VBox/ButtonsContainer/RejectBtn

var proposal_type: ProposalType = ProposalType.PEACE
# NO guardamos datos - todo viene del servidor en tiempo real

func _ready() -> void:
	close_requested.connect(_on_close_requested)
	_update_buttons_state()

func _on_close_requested() -> void:
	hide()

## Muestra las propuestas recibidas del servidor (sin guardarlas)
func set_proposals(type: ProposalType, guild_list: Array) -> void:
	proposal_type = type
	
	# Actualizar título
	if proposal_type == ProposalType.PEACE:
		title = "Propuestas de Paz"
	else:
		title = "Propuestas de Alianza"
	
	# Mostrar lista
	proposals_list.clear()
	for guild_name in guild_list:
		if !guild_name.is_empty():
			proposals_list.add_item(guild_name)
	
	selected_label.text = "Selecciona un clan"
	_update_buttons_state()

func _on_proposals_list_item_selected(index: int) -> void:
	var guild_name = proposals_list.get_item_text(index)
	selected_label.text = "Clan seleccionado: " + guild_name
	_update_buttons_state()

func _update_buttons_state() -> void:
	var has_selection = proposals_list.get_selected_items().size() > 0
	details_btn.disabled = !has_selection
	accept_btn.disabled = !has_selection
	reject_btn.disabled = !has_selection

func _on_details_btn_pressed() -> void:
	var selected = proposals_list.get_selected_items()
	if selected.size() == 0:
		return
	
	var guild_name = proposals_list.get_item_text(selected[0])
	if proposal_type == ProposalType.PEACE:
		GameProtocol.WriteGuildPeaceDetails(guild_name)
	else:
		GameProtocol.WriteGuildAllianceDetails(guild_name)

func _on_accept_btn_pressed() -> void:
	var selected = proposals_list.get_selected_items()
	if selected.size() == 0:
		return
	
	var guild_name = proposals_list.get_item_text(selected[0])
	var confirm_dialog = ConfirmationDialog.new()
	var type_text = "paz" if proposal_type == ProposalType.PEACE else "alianza"
	confirm_dialog.dialog_text = "¿Estás seguro de que deseas aceptar la propuesta de %s con %s?" % [type_text, guild_name]
	confirm_dialog.title = "Confirmar Aceptación"
	confirm_dialog.confirmed.connect(func():
		if proposal_type == ProposalType.PEACE:
			GameProtocol.WriteGuildAcceptPeace(guild_name)
		else:
			GameProtocol.WriteGuildAcceptAlliance(guild_name)
		hide()
	)
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

func _on_reject_btn_pressed() -> void:
	var selected = proposals_list.get_selected_items()
	if selected.size() == 0:
		return
	
	var guild_name = proposals_list.get_item_text(selected[0])
	var confirm_dialog = ConfirmationDialog.new()
	var type_text = "paz" if proposal_type == ProposalType.PEACE else "alianza"
	confirm_dialog.dialog_text = "¿Estás seguro de que deseas rechazar la propuesta de %s con %s?" % [type_text, guild_name]
	confirm_dialog.title = "Confirmar Rechazo"
	confirm_dialog.confirmed.connect(func():
		if proposal_type == ProposalType.PEACE:
			GameProtocol.WriteGuildRejectPeace(guild_name)
		else:
			GameProtocol.WriteGuildRejectAlliance(guild_name)
		hide()
	)
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

func _on_close_btn_pressed() -> void:
	hide()
