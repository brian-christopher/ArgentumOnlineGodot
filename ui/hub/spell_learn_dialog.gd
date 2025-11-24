extends Window
class_name SpellLearnDialog

signal spell_learn_confirmed(learn: bool)

func _ready() -> void:
	# Conectar señales de los botones
	$VBox/ButtonsContainer/AcceptButton.pressed.connect(_on_accept_button_pressed)
	$VBox/ButtonsContainer/CancelButton.pressed.connect(_on_cancel_button_pressed)
	
	# Conectar señal de cierre de ventana
	close_requested.connect(_on_cancel_button_pressed)

func set_spell_name(spell_name: String) -> void:
	$VBox/SpellNameLabel.text = spell_name

func _on_accept_button_pressed() -> void:
	spell_learn_confirmed.emit(true)
	queue_free()

func _on_cancel_button_pressed() -> void:
	spell_learn_confirmed.emit(false)
	queue_free()
