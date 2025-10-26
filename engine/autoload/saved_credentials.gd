extends Node

const CREDENTIALS_FILE = "user://saved_credentials.dat"
const SSL_FILE = "user://network_settings.cfg"

func save_credentials(username: String, password: String) -> void:
	var file = FileAccess.open(CREDENTIALS_FILE, FileAccess.WRITE)
	if file:
		file.store_string(username + "\n" + password)
		file.close()

func load_credentials() -> Dictionary:
	if FileAccess.file_exists(CREDENTIALS_FILE):
		var file = FileAccess.open(CREDENTIALS_FILE, FileAccess.READ)
		if file:
			var username = file.get_line()
			var password = file.get_line()
			file.close()
			return {"username": username, "password": password}
	
	return {"username": "", "password": ""}

func clear_credentials() -> void:
	if FileAccess.file_exists(CREDENTIALS_FILE):
		DirAccess.remove_absolute(CREDENTIALS_FILE)

func save_ssl_preference(enabled: bool) -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("network", "use_ssl", enabled)
	cfg.save(SSL_FILE)

func load_ssl_preference() -> bool:
	var cfg = ConfigFile.new()
	if cfg.load(SSL_FILE) == OK:
		return bool(cfg.get_value("network", "use_ssl", false))
	return false
