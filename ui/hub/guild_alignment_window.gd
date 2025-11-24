extends Window

# Enumeración de tipos de alineación de gremio
# Debe coincidir exactamente con eAlineacion en el servidor
enum AlignmentType {
	REAL = 0,      # ieREAL
	CAOS = 1,      # ieCAOS
	NEUTRAL = 2,   # ieNeutral
	LEGAL = 4,     # ieLegal
	CRIMINAL = 5   # ieCriminal
}

func _ready() -> void:
	print("[DEBUG] GuildAlignmentWindow _ready() iniciado")
	
	# Conectar señales de los botones
	$VBox/RealButton.pressed.connect(_on_alignment_button_pressed.bind(AlignmentType.REAL))
	$VBox/ChaosButton.pressed.connect(_on_alignment_button_pressed.bind(AlignmentType.CAOS))
	$VBox/NeutralButton.pressed.connect(_on_alignment_button_pressed.bind(AlignmentType.NEUTRAL))
	$VBox/LegalButton.pressed.connect(_on_alignment_button_pressed.bind(AlignmentType.LEGAL))
	$VBox/CriminalButton.pressed.connect(_on_alignment_button_pressed.bind(AlignmentType.CRIMINAL))
	$VBox/ButtonsContainer/CloseButton.pressed.connect(_on_close_button_pressed)
	
	# Conectar señal de cierre de la ventana
	close_requested.connect(_on_close_requested)
	
	print("[DEBUG] GuildAlignmentWindow señales conectadas correctamente")

# Manejador para cuando se presiona la X de la ventana
func _on_close_requested() -> void:
	queue_free()

# Manejador para el botón de cierre
func _on_close_button_pressed() -> void:
	hide()
	queue_free()

# Manejador para los botones de alineación
func _on_alignment_button_pressed(alignment_type: int) -> void:
	print("[DEBUG] Botón de alineación presionado: ", alignment_type)
	
	# Enviar la alineación seleccionada al servidor
	print("[DEBUG] Enviando WriteGuildFundation al servidor...")
	GameProtocol.WriteGuildFundation(alignment_type)
	print("[DEBUG] WriteGuildFundation enviado")
	
	# Cerrar la ventana
	hide()
	queue_free()
