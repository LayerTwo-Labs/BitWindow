extends Control

# Bitcoin RPC requests 
@onready var http_rpc_btc_get_block_count: HTTPRequest = $RPCRequests/HTTPRPCBTCGetBlockCount
@onready var http_rpc_btc_get_network_info: HTTPRequest = $RPCRequests/HTTPRPCBTCGetNetworkInfo
@onready var http_rpc_btc_get_mempool_info: HTTPRequest = $RPCRequests/HTTPRPCBTCGetMempoolInfo
@onready var http_rpc_btc_get_blockchain_info: HTTPRequest = $RPCRequests/HTTPRPCBTCGetBlockchainInfo

# Wallet RPC Requests
@onready var http_rpc_wallet_get_balance: HTTPRequest = $RPCRequests/HTTPRPCWalletGetBalance

# OP_CAT CUSF Client RPC Requests
@onready var httprpccusfcat_get_block_count: HTTPRequest = $RPCRequests/HTTPRPCCUSFCATGetBlockCount

# Drivechain CUSF client RPC Requests
@onready var http_rpc_cusf_cat_get_block_count: HTTPRequest = $RPCRequests/HTTPRPCCUSFCATGetBlockCount
@onready var http_rpc_cusf_drivechain_get_block_count: HTTPRequest = $RPCRequests/HTTPRPCCUSFDRIVECHAINGetBlockCount


# Signals that should be emitted regularly if connections are working
signal btc_new_block_count(height : int)
signal btc_new_network_info(subversion : String, services : String, connections : int)
signal btc_new_mempool_info(size : int, bytesize : int)
signal btc_new_blockchain_info(bestblockhash : String, bytes : int, warnings : String, time : int)

signal wallet_updated(btc_balance : int)

signal cusf_cat_new_block_count(height : int)
signal cusf_drivechain_new_block_count(height : int)

# Signals that indicate connection failure to one of the backend softwares 
signal btc_rpc_failed()
signal wallet_rpc_failed()
signal cusf_cat_rpc_failed()
signal cusf_drivechain_rpc_failed()


func _on_button_test_connection_bitcoin_pressed() -> void:
	rpc_bitcoin_getblockcount()
	rpc_cusf_cat_getblockcount()
	rpc_cusf_drivechain_getblockcount()
	rpc_wallet_getbalance()


func make_rpc_request(port : int, method: String, params: Variant, http_request: HTTPRequest) -> void:
	var auth = str($"/root/UserSettings".rpc_user, ":", $"/root/UserSettings".rpc_pass)
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
				printerr(json.get_data())
	else:
		var err = json.parse(body.get_string_from_utf8())
		if err == OK:
			res = json.get_data() as Dictionary
	
	return res


func rpc_bitcoin_getblockcount() -> void:
	make_rpc_request($"/root/UserSettings".rpc_port_bitcoin, "getblockcount", [], http_rpc_btc_get_block_count)


func rpc_bitcoin_getnetworkinfo() -> void:
	make_rpc_request($"/root/UserSettings".rpc_port_bitcoin, "getnetworkinfo", [], http_rpc_btc_get_network_info)


func rpc_bitcoin_getmempoolinfo() -> void:
	make_rpc_request($"/root/UserSettings".rpc_port_bitcoin, "getmempoolinfo", [], http_rpc_btc_get_mempool_info)


func rpc_bitcoin_getblockchaininfo() -> void:
	make_rpc_request($"/root/UserSettings".rpc_port_bitcoin, "getblockchaininfo", [], http_rpc_btc_get_blockchain_info)


func rpc_wallet_getbalance() -> void:
	make_rpc_request($"/root/UserSettings".rpc_port_wallet, "getbalance", [], http_rpc_wallet_get_balance)
	
	
func rpc_cusf_cat_getblockcount() -> void:
	make_rpc_request($"/root/UserSettings".rpc_port_cusf_cat, "getblockcount", [], http_rpc_cusf_cat_get_block_count)


func rpc_cusf_drivechain_getblockcount() -> void:
	make_rpc_request($"/root/UserSettings".rpc_port_cusf_drivechain, "getblockcount", [], http_rpc_cusf_drivechain_get_block_count)


func _on_httprpcbtc_get_block_count_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	var height : int = 0
	if res.has("result"):
		#print_debug("Result: ", res.result)
		height = res.result
		btc_new_block_count.emit(height)
	else:
		print_debug("result error")
		btc_rpc_failed.emit()


func _on_httprpcbtc_get_network_info_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	if res.has("result"):
		#print_debug("Result: ", res.result)
		if not res["result"].has("subversion"):
			btc_rpc_failed.emit()
			return
			
		if not res["result"].has("localservicesnames"):
			btc_rpc_failed.emit()
			return
			
		if not res["result"].has("connections"):
			btc_rpc_failed.emit()
			return
			
		var subversion : String = res["result"]["subversion"]
		
		var services : String = ""
		for service in res["result"]["localservicesnames"]:
			services += str(service, " ")
		
		var peers : int = res["result"]["connections"]
		
		btc_new_network_info.emit(subversion, services, peers)
	else:
		print_debug("result error")
		btc_rpc_failed.emit()
		
		
func _on_http_rpc_btc_get_mempool_info_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	if res.has("result"):
		#print_debug("Result: ", res.result)
		if not res["result"].has("size"):
			btc_rpc_failed.emit()
			return
			
		if not res["result"].has("bytes"):
			btc_rpc_failed.emit()
			return
			
		var mempool_size : int = res["result"]["size"]
		var mempool_bytes : int = res["result"]["bytes"]
		
		btc_new_mempool_info.emit(mempool_size, mempool_bytes)
	else:
		print_debug("result error")
		btc_rpc_failed.emit()


func _on_http_rpc_btc_get_blockchain_info_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	if res.has("result"):
		#print_debug("Result: ", res.result)
		if not res["result"].has("bestblockhash"):
			btc_rpc_failed.emit()
			return
		
		if not res["result"].has("size_on_disk"):
			btc_rpc_failed.emit()
			return
			
		if not res["result"].has("warnings"):
			btc_rpc_failed.emit()
			return
			
		if not res["result"].has("time"):
			btc_rpc_failed.emit()
			return
			
		var blockchain_best_hash : String = res["result"]["bestblockhash"]
		var blockchain_disk_bytes : int = res["result"]["size_on_disk"]
		var blockchain_warnings : String = res["result"]["warnings"]
		var blockchain_time : int = res["result"]["time"]
		
		btc_new_blockchain_info.emit(blockchain_best_hash, blockchain_disk_bytes, blockchain_warnings, blockchain_time)
	else:
		print_debug("result error")
		btc_rpc_failed.emit()


func _on_httprpc_wallet_get_balance_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	var balance : int = 0
	if res.has("result"):
		#print_debug("Result: ", res.result)
		balance = res.result
		wallet_updated.emit(balance)
	else:
		print_debug("result error")
		wallet_rpc_failed.emit()


func _on_http_rpc_cusf_cat_get_block_count_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	var height : int = 0
	if res.has("result"):
		#print_debug("Result: ", res.result)
		height = res.result
		cusf_cat_new_block_count.emit(height)
	else:
		print_debug("result error")
		cusf_cat_rpc_failed.emit()


func _on_http_rpc_cusf_drivechain_get_block_count_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	var height : int = 0
	if res.has("result"):
		#print_debug("Result: ", res.result)
		height = res.result
		cusf_drivechain_new_block_count.emit(height)
	else:
		print_debug("result error")
		cusf_drivechain_rpc_failed.emit()
