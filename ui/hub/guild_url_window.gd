extends Window
class_name GuildURLWindow

## Ventana de edición de URL del clan
## Replica la funcionalidad de frmGuildURL.frm del cliente VB6

@onready var url_input: LineEdit = $VBox/URLInput

func _ready() -> void:
	close_requested.connect(_on_close_requested)

func _on_close_requested() -> void:
	hide()

func _on_confirm_btn_pressed() -> void:
	var url = url_input.text.strip_edges()
	
	if url.is_empty():
		var error_dialog = AcceptDialog.new()
		error_dialog.dialog_text = "Debes ingresar una URL válida."
		error_dialog.title = "Error"
		add_child(error_dialog)
		error_dialog.popup_centered()
		return
	
	GameProtocol.WriteGuildNewWebsite(url)
	hide()

func _on_cancel_btn_pressed() -> void:
	hide()
