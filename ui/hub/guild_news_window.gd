extends Window
class_name GuildNewsWindow

## Ventana de noticias del clan
## Replica la funcionalidad de frmGuildNews.frm del cliente VB6

@onready var news_text: TextEdit = $VBox/NewsScroll/NewsText
@onready var enemies_text: TextEdit = $VBox/EnemiesScroll/EnemiesText
@onready var allies_text: TextEdit = $VBox/AlliesScroll/AlliesText

func _ready() -> void:
	close_requested.connect(_on_close_requested)

func _on_close_requested() -> void:
	hide()

## Establece las noticias y listas del clan
func set_guild_news(news: String, enemies: Array, allies: Array) -> void:
	# Reemplazar el separador especial por saltos de línea
	news_text.text = news.replace("º", "\n")
	
	# Construir lista de enemigos
	var enemies_list = ""
	for enemy in enemies:
		if !enemy.is_empty():
			enemies_list += enemy + "\n"
	enemies_text.text = enemies_list
	
	# Construir lista de aliados
	var allies_list = ""
	for ally in allies:
		if !ally.is_empty():
			allies_list += ally + "\n"
	allies_text.text = allies_list

func _on_close_btn_pressed() -> void:
	hide()
