extends Node

enum State {
	None,
	Login,
	NewPj
}

@export var _loginPanel:LoginPanel

var _state:State

func _ready() -> void:
	ClientInterface.connected.connect(_OnConnected)
	ClientInterface.disconnected.connect(_OnDisconnected)
	ClientInterface.connection_timeout.connect(_OnConnectionTimeout)
	ClientInterface.dataReceived.connect(_OnDataReceived)
	
	_loginPanel.error.connect(func(message): 
		Utils.ShowAlertDialog("Login", message, self)) 
	
func _OnConnected() -> void:
	if _state == State.NewPj:
		var screen = load("uid://bp35uafwebjdb").instantiate()
		ScreenController.SwitchScreen(screen)
	elif _state == State.Login:
		GameProtocol.WriteLoginExistingCharacter(_loginPanel.GetUsername(), _loginPanel.GetPassword())
		_Flush()
	
func _OnDisconnected() -> void:
	_state = State.None
	_loginPanel.EnableAuthControls()

func _OnConnectionTimeout() -> void:
	_state = State.None
	_loginPanel.EnableAuthControls()
	Utils.ShowAlertDialog("Error de Conexión", "No se pudo conectar al servidor.\nEl intento de conexión ha excedido el tiempo límite.", self)
	
func _GetEnpoint() -> Dictionary:
	return {
		"ip": %Ip.text,
		"port": int(%Port.value)
	}

func _OnDataReceived(data:PackedByteArray) -> void:
	var stream = StreamPeerBuffer.new()
	stream.data_array = data
	
	while stream.get_position() < stream.get_size():
		var packetId = stream.get_u8()
		match packetId:
			Enums.ServerPacketID.ErrorMsg:
				_HandleErrorMsg(Utils.GetUnicodeString(stream))
			_:
				_HandleLogged(data)
				return

func _HandleErrorMsg(message:String) -> void:
	Utils.ShowAlertDialog("Server", message, self)
	ClientInterface.DisconnectFromHost()

func _HandleLogged(data:PackedByteArray) -> void:
	var screen = load("uid://b2dyxo3826bub").instantiate() as GameScreen
	screen.networkMessages.append(data)
	
	ScreenController.SwitchScreen(screen)
		
func _OnLoginPanelSubmit() -> void:
	_ConnectToHost(State.Login)
		
func _OnLoginPanelRegister() -> void:
	_ConnectToHost(State.NewPj)
		
func _ConnectToHost(state:State) -> void:
	#if ClientInterface.IsConnected():
	#	ClientInterface.DisconnectFromHost()
		
	_state = state
	_loginPanel.DisableAuthControls()
	
	var endpoint = _GetEnpoint()
	ClientInterface.ConnectToHost(endpoint.ip, endpoint.port)

func _Flush() -> void:
	ClientInterface.Send(GameProtocol.Flush());
