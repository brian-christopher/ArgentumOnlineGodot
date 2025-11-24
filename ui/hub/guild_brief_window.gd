extends Window
class_name GuildBriefWindow

## Ventana de detalles del clan
## Replica la funcionalidad de frmGuildBrief.frm del cliente VB6

# Referencias a nodos de información básica
@onready var name_value: Label = $MainScroll/VBox/BasicInfo/HBoxContainer/GridContainer/NameValue
@onready var founder_value: Label = $MainScroll/VBox/BasicInfo/HBoxContainer/GridContainer/FounderValue
@onready var creation_value: Label = $MainScroll/VBox/BasicInfo/HBoxContainer/GridContainer/CreationValue
@onready var leader_value: Label = $MainScroll/VBox/BasicInfo/HBoxContainer/GridContainer/LeaderValue
@onready var web_value: Label = $MainScroll/VBox/BasicInfo/HBoxContainer/GridContainer/WebValue
@onready var members_value: Label = $MainScroll/VBox/BasicInfo/HBoxContainer/GridContainer/MembersValue
@onready var election_value: Label = $MainScroll/VBox/BasicInfo/HBoxContainer/GridContainer2/ElectionValue
@onready var alignment_value: Label = $MainScroll/VBox/BasicInfo/HBoxContainer/GridContainer2/AlignmentValue
@onready var enemies_value: Label = $MainScroll/VBox/BasicInfo/HBoxContainer/GridContainer2/EnemiesValue
@onready var allies_value: Label = $MainScroll/VBox/BasicInfo/HBoxContainer/GridContainer2/AlliesValue
@onready var anti_faction_value: Label = $MainScroll/VBox/BasicInfo/HBoxContainer/GridContainer2/AntiFactionValue

# Referencias a nodos de códex
@onready var codex_container: VBoxContainer = $MainScroll/VBox/CodexScroll/CodexContainer

# Referencias a descripción
@onready var desc_text: TextEdit = $MainScroll/VBox/DescText

# Referencias a botones
@onready var leader_buttons: HBoxContainer = $MainScroll/VBox/LeaderButtons
@onready var offer_peace_btn: Button = $MainScroll/VBox/LeaderButtons/OfferPeaceBtn
@onready var offer_alliance_btn: Button = $MainScroll/VBox/LeaderButtons/OfferAllianceBtn
@onready var declare_war_btn: Button = $MainScroll/VBox/LeaderButtons/DeclareWarBtn

# NO guardamos datos - obtenemos el nombre del label cuando se necesita

func _ready() -> void:
	close_requested.connect(_on_close_requested)
	# Por defecto, ocultar botones de líder
	leader_buttons.visible = false

func _on_close_requested() -> void:
	hide()

## Muestra los datos del clan recibidos del servidor (sin guardarlos)
func set_guild_details(data: Dictionary) -> void:
	var is_leader = data.get("is_leader", false)
	
	# Actualizar información básica
	name_value.text = data.get("name", "")
	founder_value.text = data.get("founder", "-")
	creation_value.text = data.get("creation_date", "-")
	leader_value.text = data.get("leader", "-")
	web_value.text = data.get("website", "-")
	members_value.text = str(data.get("members_count", 0))
	
	var elections_open = data.get("elections_open", false)
	election_value.text = "ABIERTA" if elections_open else "CERRADA"
	
	alignment_value.text = data.get("alignment", "-")
	enemies_value.text = str(data.get("enemies_count", 0))
	allies_value.text = str(data.get("allies_count", 0))
	anti_faction_value.text = data.get("anti_faction", "-")
	
	# Actualizar códex
	var codex_array = data.get("codex", [])
	for i in range(8):
		var codex_label = codex_container.get_child(i) as Label
		if i < codex_array.size():
			codex_label.text = codex_array[i]
			codex_label.visible = !codex_array[i].is_empty()
		else:
			codex_label.text = ""
			codex_label.visible = false
	
	# Actualizar descripción
	desc_text.text = data.get("description", "")
	
	# Mostrar/ocultar botones de líder
	leader_buttons.visible = is_leader

func _on_offer_peace_btn_pressed() -> void:
	var guild_name = name_value.text
	if guild_name.is_empty():
		return
	
	var input_dialog = _create_proposal_dialog("Propuesta de Paz", "Ingresa la propuesta de paz:")
	input_dialog.confirmed.connect(func():
		var proposal_text = input_dialog.get_node("VBox/ProposalText") as TextEdit
		GameProtocol.WriteGuildOfferPeace(guild_name, proposal_text.text)
	)
	add_child(input_dialog)
	input_dialog.popup_centered()

func _on_offer_alliance_btn_pressed() -> void:
	var guild_name = name_value.text
	if guild_name.is_empty():
		return
	
	var input_dialog = _create_proposal_dialog("Propuesta de Alianza", "Ingresa la propuesta de alianza:")
	input_dialog.confirmed.connect(func():
		var proposal_text = input_dialog.get_node("VBox/ProposalText") as TextEdit
		GameProtocol.WriteGuildOfferAlliance(guild_name, proposal_text.text)
	)
	add_child(input_dialog)
	input_dialog.popup_centered()

func _on_declare_war_btn_pressed() -> void:
	var guild_name = name_value.text
	if guild_name.is_empty():
		return
	
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.dialog_text = "¿Estás seguro de que deseas declarar la guerra a %s?" % guild_name
	confirm_dialog.title = "Confirmar Declaración de Guerra"
	confirm_dialog.confirmed.connect(func():
		GameProtocol.WriteGuildDeclareWar(guild_name)
		hide()
	)
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

func _on_request_membership_btn_pressed() -> void:
	var guild_name = name_value.text
	if guild_name.is_empty():
		return
	
	var input_dialog = _create_proposal_dialog("Solicitud de Ingreso", "Escribe tu solicitud de ingreso:")
	input_dialog.confirmed.connect(func():
		var application_text = input_dialog.get_node("VBox/ProposalText") as TextEdit
		GameProtocol.WriteGuildRequestMembership(guild_name, application_text.text)
	)
	add_child(input_dialog)
	input_dialog.popup_centered()

func _on_close_btn_pressed() -> void:
	hide()

## Crea un diálogo para ingresar propuestas o solicitudes
func _create_proposal_dialog(title_text: String, label_text: String) -> ConfirmationDialog:
	var dialog = ConfirmationDialog.new()
	dialog.title = title_text
	dialog.size = Vector2i(400, 300)
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	
	var label = Label.new()
	label.text = label_text
	vbox.add_child(label)
	
	var text_edit = TextEdit.new()
	text_edit.name = "ProposalText"
	text_edit.custom_minimum_size = Vector2(0, 150)
	vbox.add_child(text_edit)
	
	dialog.add_child(vbox)
	
	return dialog
