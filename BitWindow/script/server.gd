extends Control

const RPC_USER : String = "abc"
const RPC_PASS : String = "def"

const BITCOIN_RPC_PORT : int = 8332

@onready var http_rpc_btc_get_block_count: HTTPRequest = $RPCRequests/HTTPRPCBTCGetBlockCount

signal btc_new_block_count(height : int)


func _on_button_test_connection_bitcoin_pressed() -> void:
	rpc_bitcoin_getblockcount()


func make_rpc_request(port : int, method: String, params: Variant, http_request: HTTPRequest) -> void:
	var auth = str(RPC_USER, ":", RPC_PASS)
	var auth_bytes = auth.to_utf8_buffer()
	var auth_encoded = Marshalls.raw_to_base64(auth_bytes)
	var headers: PackedStringArray = []
	headers.push_back("Authorization: Basic " + auth_encoded)
	headers.push_back("content-type: application/json")
	
	var jsonrpc := JSONRPC.new()
	var req = jsonrpc.make_request(method, params, 1)
	
	http_request.request("http://127.0.0.1:" + str(port), headers, HTTPClient.METHOD_POST, JSON.stringify(req))


func parse_rpc_result(response_code, body) -> Dictionary:
	var res = {}
	var json = JSON.new()
	if response_code != 200:
		if body != null:
			var err = json.parse(body.get_string_from_utf8())
			if err == OK:
				print(json.get_data())
	else:
		var err = json.parse(body.get_string_from_utf8())
		if err == OK:
			res = json.get_data() as Dictionary
	
	return res


func rpc_bitcoin_getblockcount() -> void:
	make_rpc_request(BITCOIN_RPC_PORT, "getblockcount", [], http_rpc_btc_get_block_count)


func _on_httprpcbtc_get_block_count_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	var height : int = 0
	if res.has("result"):
		print_debug("Result: ", res.result)
		height = res.result
		btc_new_block_count.emit(height)
	else:
		print_debug("result error")
