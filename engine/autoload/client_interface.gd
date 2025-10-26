extends Node

signal connected
signal disconnected
signal dataReceived(data:PackedByteArray)

# Constante para habilitar/deshabilitar el log de paquetes
const LOG_PACKETS := true

var _tcp_peer:StreamPeerTCP = StreamPeerTCP.new()
var _tls_peer:StreamPeerTLS = null
var _status:int
var _use_ssl:bool = false
var _host_for_ssl:String = ""
var _tls_pending_error:bool = false

func _ready() -> void:
	_status = StreamPeerTCP.STATUS_NONE
	_tls_peer = null
	set_process(false)

func ConnectToHost(host:String, port:int, use_ssl:bool = false) -> void:
	_use_ssl = use_ssl
	_host_for_ssl = host
	_tls_pending_error = false
	_tls_peer = null
	_tcp_peer = StreamPeerTCP.new()
	_status = StreamPeerTCP.STATUS_NONE
	var err := _tcp_peer.connect_to_host(host, port)
	set_process(err == OK)
	if err != OK:
		disconnected.emit()

func DisconnectFromHost() -> void:
	if _tls_peer:
		_tls_peer.disconnect_from_stream()
		_tls_peer = null
	_tcp_peer.disconnect_from_host()
	_use_ssl = false

func Send(data:PackedByteArray) -> void:
	if data.size() == 0:
		return

	if _use_ssl:
		if _tls_peer and _tls_peer.get_status() == StreamPeerTLS.STATUS_CONNECTED:
			_tls_peer.put_data(data)
	elif _tcp_peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		_tcp_peer.put_data(data)
		
func _process(_delta: float) -> void:
	_tcp_peer.poll()
	if _use_ssl and _tls_peer:
		_tls_peer.poll()

	if _use_ssl and _tcp_peer.get_status() == StreamPeerTCP.STATUS_CONNECTED and _tls_peer == null and not _tls_pending_error:
		_initialize_tls()

	var new_status := _get_effective_status()
	if new_status != _status:
		_status = new_status
		match _status:
			StreamPeerTCP.STATUS_NONE:
				disconnected.emit()
			StreamPeerTCP.STATUS_CONNECTING:
				pass
			StreamPeerTCP.STATUS_CONNECTED:
				connected.emit()
			StreamPeerTCP.STATUS_ERROR:
				disconnected.emit()
				set_process(false)

	if _status == StreamPeerTCP.STATUS_CONNECTED:
		var peer := _get_active_peer()
		if peer:
			var available_bytes := peer.get_available_bytes()
			if available_bytes > 0:
				var response := peer.get_partial_data(available_bytes)
				if response[0] != OK:
					disconnected.emit()
					set_process(false)
				else:
					var data:PackedByteArray = response[1]
					if LOG_PACKETS and data.size() > 0:
						var packet_id := -1
						var packet_length := 0
						if data.size() >= 1:
							packet_id = data[0]
						if data.size() >= 3:
							packet_length = (data[2] << 8) | data[1]
						var hex_str := ""
						for i in range(min(8, data.size())):
							hex_str += "%02X " % data[i]
						print("[INCOMING] Packet ID: %d (0x%02X), Longitud: %d, Bytes: %s" % [packet_id, packet_id, packet_length, hex_str])
					dataReceived.emit(data)

func _initialize_tls() -> void:
	_tls_peer = StreamPeerTLS.new()
	var tls_options := TLSOptions.client_unsafe()
	var err := _tls_peer.connect_to_stream(_tcp_peer, _host_for_ssl, tls_options)
	if err != OK:
		push_error("No se pudo iniciar conexión TLS: %s" % [err])
		_tls_peer = null
		_tls_pending_error = true

func _get_effective_status() -> int:
	var tcp_status := _tcp_peer.get_status()
	if not _use_ssl:
		return tcp_status

	if tcp_status == StreamPeerTCP.STATUS_ERROR:
		return tcp_status
	if tcp_status == StreamPeerTCP.STATUS_NONE:
		return tcp_status
	if tcp_status == StreamPeerTCP.STATUS_CONNECTING:
		return tcp_status
	if _tls_pending_error:
		return StreamPeerTCP.STATUS_ERROR
	if _tls_peer == null:
		return StreamPeerTCP.STATUS_CONNECTING

	var tls_status := _tls_peer.get_status()
	match tls_status:
		StreamPeerTLS.STATUS_HANDSHAKING:
			return StreamPeerTCP.STATUS_CONNECTING
		StreamPeerTLS.STATUS_CONNECTED:
			return StreamPeerTCP.STATUS_CONNECTED
		StreamPeerTLS.STATUS_DISCONNECTED:
			_tls_peer = null
			return StreamPeerTCP.STATUS_NONE
		StreamPeerTLS.STATUS_ERROR:
			_tls_peer = null
			_tls_pending_error = true
			return StreamPeerTCP.STATUS_ERROR
		_:
			return StreamPeerTCP.STATUS_CONNECTING

func _get_active_peer() -> StreamPeer:
	if _use_ssl and _tls_peer and _tls_peer.get_status() == StreamPeerTLS.STATUS_CONNECTED:
		return _tls_peer
	return _tcp_peer
