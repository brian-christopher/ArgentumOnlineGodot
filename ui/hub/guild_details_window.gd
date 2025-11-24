extends Window
class_name GuildDetailsWindow

## Ventana de edición de códex y descripción del clan
## Replica la funcionalidad de frmGuildDetails.frm del cliente VB6

const MAX_DESC_LENGTH = 520
const MAX_CODEX_LENGTH = 100

@onready var desc_text: TextEdit = $VBox/DescText
@onready var codex_container: VBoxContainer = $VBox/CodexScroll/CodexContainer

# Variables para modo de creación de clan
var creating_clan: bool = false
var clan_name: String = ""
var clan_site: String = ""

func _ready() -> void:
	close_requested.connect(_on_close_requested)
	# Limitar longitud de descripción
	desc_text.text_changed.connect(_on_desc_text_changed)

func _on_close_requested() -> void:
	hide()

## Configura la ventana para crear un nuevo clan
func setup_for_creation(guild_name: String, site: String) -> void:
	creating_clan = true
	clan_name = guild_name
	clan_site = site
	title = "Crear Códex del Nuevo Clan"

## Obtiene un LineEdit de códex por índice
func _get_codex_line_edit(index: int) -> LineEdit:
	var container_name = "HBoxContainer" if index == 0 else "HBoxContainer" + str(index + 1)
	return codex_container.get_node(container_name + "/Codex" + str(index)) as LineEdit

func _on_confirm_btn_pressed() -> void:
	# Recopilar códex
	var codex_array: Array = []
	var filled_count = 0
	
	for i in range(8):
		var line_edit = _get_codex_line_edit(i)
		var text = line_edit.text.strip_edges()
		codex_array.append(text)
		if !text.is_empty():
			filled_count += 1
	
	# Validar que haya al menos 4 mandamientos
	if filled_count < 4:
		var error_dialog = AcceptDialog.new()
		error_dialog.dialog_text = "Debes definir al menos cuatro mandamientos."
		error_dialog.title = "Error"
		add_child(error_dialog)
		error_dialog.popup_centered()
		return
	
	# Reemplazar saltos de línea en descripción (como en VB6)
	var description = desc_text.text.replace("\n", "º")
	
	if creating_clan:
		# Crear nuevo clan
		GameProtocol.WriteCreateNewGuild(description, clan_name, clan_site, codex_array)
	else:
		# Actualizar códex existente
		GameProtocol.WriteClanCodexUpdate(description, codex_array)
	
	hide()

func _on_cancel_btn_pressed() -> void:
	hide()

func _on_desc_text_changed() -> void:
	# Limitar longitud de la descripción
	if desc_text.text.length() > MAX_DESC_LENGTH:
		desc_text.text = desc_text.text.substr(0, MAX_DESC_LENGTH)
		# Mover el cursor al final
		desc_text.set_caret_column(MAX_DESC_LENGTH)
