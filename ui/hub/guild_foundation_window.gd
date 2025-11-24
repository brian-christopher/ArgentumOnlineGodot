extends Window
class_name GuildFoundationWindow

# Señal que se emite cuando se presiona el botón Siguiente
signal next_pressed(clan_name: String, clan_url: String)
# Señal que se emite cuando se cierra la ventana
signal window_closed()

# Referencias a los nodos de la interfaz
@onready var _clan_name_edit: LineEdit = $VBox/FormContainer/ClanNameEdit
@onready var _url_edit: LineEdit = $VBox/FormContainer/UrlEdit
@onready var _next_button: Button = $VBox/ButtonsContainer/NextButton
@onready var _cancel_button: Button = $VBox/ButtonsContainer/CancelButton

func _ready() -> void:
	# Conectar señales de los botones
	_next_button.pressed.connect(_on_next_pressed)
	_cancel_button.pressed.connect(_on_cancel_pressed)
	
	# Configurar cierre con ESC
	close_requested.connect(_on_cancel_pressed)
	
	# Configurar para que se cierre la ventana cuando se presiona Enter en los campos de texto
	_clan_name_edit.gui_input.connect(_on_edit_gui_input.bind(_clan_name_edit))
	_url_edit.gui_input.connect(_on_edit_gui_input.bind(_url_edit))

# Muestra la ventana centrada y limpia los campos
func show_window() -> void:
	_clan_name_edit.clear()
	_url_edit.clear()
	popup_centered()
	_clan_name_edit.grab_focus()

# Se llama cuando se presiona el botón Siguiente
func _on_next_pressed() -> void:
	var clan_name = _clan_name_edit.text.strip_edges()
	var url = _url_edit.text.strip_edges()
	
	# Validaciones básicas
	if clan_name.is_empty():
		_show_error("Debes ingresar un nombre para el clan.")
		_clan_name_edit.grab_focus()
		return
	
	# Validar longitud del nombre (máximo 30 caracteres como en VB6)
	if clan_name.length() > 30:
		_show_error("El nombre del clan es demasiado extenso (máximo 30 caracteres).")
		_clan_name_edit.grab_focus()
		return
	
	# Si no se proporciona URL, dejarla vacía
	if url.is_empty():
		url = ""
	
	# Emitir señal con los datos del formulario
	next_pressed.emit(clan_name, url)
	hide()

# Se llama cuando se presiona el botón Cancelar
func _on_cancel_pressed() -> void:
	window_closed.emit()
	hide()

# Muestra un mensaje de error
func _show_error(message: String) -> void:
	# Aquí deberías implementar la lógica para mostrar el mensaje de error al jugador
	# Por ejemplo, usando una etiqueta de error o un diálogo
	print("Error: ", message)

# Maneja el evento de entrada en los campos de texto
func _on_edit_gui_input(event: InputEvent, edit: LineEdit) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			get_viewport().set_input_as_handled()
			if edit == _clan_name_edit:
				_url_edit.grab_focus()
			else:
				_on_next_pressed()
