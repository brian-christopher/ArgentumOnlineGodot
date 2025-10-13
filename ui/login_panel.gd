extends PanelContainer
class_name LoginPanel

signal submit 
signal register
signal error(message:String)

func _ready() -> void:
	%Reg.pressed.connect(func(): register.emit())
	%ShowPasswordButton.toggled.connect(_on_show_password_toggled)
	%ShowPasswordButton.toggle_mode = true
	%ShowPasswordButton.button_pressed = false
	
	# Set initial button text based on OS
	_update_password_button_text(false)
	
	# Load saved credentials if they exist
	var credentials = SavedCredentials.load_credentials()
	if credentials.username != "" and credentials.password != "":
		%Username.text = credentials.username
		%Password.text = credentials.password
		%RememberPassword.button_pressed = true

func _on_show_password_toggled(button_pressed: bool) -> void:
	%Password.secret = !button_pressed
	_update_password_button_text(button_pressed)

func _update_password_button_text(showing_password: bool) -> void:
	var is_windows = OS.get_name() == "Windows"
	
	if showing_password:
		if is_windows:
			%ShowPasswordButton.text = "🙈"
		else:
			%ShowPasswordButton.text = "Ocultar"
		%ShowPasswordButton.tooltip_text = "Ocultar contraseña"
	else:
		if is_windows:
			%ShowPasswordButton.text = "👁️"
		else:
			%ShowPasswordButton.text = "Ver"
		%ShowPasswordButton.tooltip_text = "Mostrar contraseña"

func GetUsername() -> String:
	return %Username.text
	
func GetPassword() -> String:
	return %Password.text

func EnableAuthControls() -> void:
	%Submit.disabled = false
	%Reg.disabled = false
	%Username.editable = true
	%Password.editable = true
	
func DisableAuthControls() -> void:
	%Submit.disabled = true
	%Reg.disabled = true
	%Username.editable = false
	%Password.editable = false

func _OnButtonLoginPressed() -> void:
	if %Username.text.is_empty():
		error.emit("Escriba el nombre del usuario")
		return 
		
	if %Username.text.length() < 3 || %Username.text.length() > 15:
		error.emit("El nombre del usuario tiene que tener un minimo de 3 caracteres y un maximo de 15 caracteres")
		return
	
	for i in %Username.text:
		if !Utils.LegalCharacter(i):
			error.emit("Nombre invalido: El caracter [{0}] no esta permitido".format([i]))
			return
		
	if %Password.text.is_empty():
		error.emit("Escriba la contraseña del usuario")
		return
		
	if %Password.text.length() < 3 || %Password.text.length() > 15:
		error.emit("La contraseña del usuario tiene que tener un minimo de 3 caracteres y un maximo de 15 caracteres")
		return
		
	for i in %Password.text:
		if !Utils.LegalCharacter(i):
			error.emit("Contraseña invalida: El caracter [{0}] no esta permitido".format([i]))
			return
			
	Global.username = %Username.text
	
	# Save credentials if checkbox is checked
	if %RememberPassword.button_pressed:
		SavedCredentials.save_credentials(%Username.text, %Password.text)
	else:
		SavedCredentials.clear_credentials()
	
	submit.emit()
