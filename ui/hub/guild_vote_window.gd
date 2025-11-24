extends Window
class_name GuildVoteWindow

## Ventana de votación para líder del clan
## Permite a los miembros votar por un nuevo líder cuando las elecciones están abiertas

@onready var filter_input: LineEdit = $VBox/FilterInput
@onready var members_list: ItemList = $VBox/MembersList
@onready var selected_label: Label = $VBox/SelectedLabel
@onready var vote_btn: Button = $VBox/ButtonsContainer/VoteBtn

# Datos
var all_members: Array = []
var filtered_members: Array = []
var selected_member: String = ""

func _ready() -> void:
	close_requested.connect(_on_close_requested)
	vote_btn.disabled = true

func _on_close_requested() -> void:
	hide()

## Establece la lista de miembros del clan que pueden ser votados
func set_members(members: Array) -> void:
	all_members = members.duplicate()
	_update_members_list()

## Actualiza la lista de miembros según el filtro
func _update_members_list() -> void:
	members_list.clear()
	var filter_text = filter_input.text.to_lower()
	
	filtered_members.clear()
	for member_name in all_members:
		if filter_text.is_empty() or member_name.to_lower().contains(filter_text):
			filtered_members.append(member_name)
			members_list.add_item(member_name)

func _on_filter_input_text_changed(_new_text: String) -> void:
	_update_members_list()

func _on_members_list_item_selected(index: int) -> void:
	if index >= 0 and index < filtered_members.size():
		selected_member = filtered_members[index]
		selected_label.text = "Candidato seleccionado: " + selected_member
		vote_btn.disabled = false

func _on_vote_btn_pressed() -> void:
	if selected_member.is_empty():
		return
	
	# Confirmar votación
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.dialog_text = "¿Estás seguro de que deseas votar por %s como líder del clan?\n\nEsta decisión es importante para el futuro de tu hermandad." % selected_member
	confirm_dialog.title = "Confirmar Voto"
	confirm_dialog.confirmed.connect(func():
		GameProtocol.WriteGuildVote(selected_member)
		hide()
		# Mostrar mensaje de confirmación
		var success_dialog = AcceptDialog.new()
		success_dialog.dialog_text = "Tu voto por %s ha sido registrado.\n¡Que los dioses guíen tu elección!" % selected_member
		success_dialog.title = "Voto Registrado"
		get_parent().add_child(success_dialog)
		success_dialog.popup_centered()
	)
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

func _on_cancel_btn_pressed() -> void:
	hide()
