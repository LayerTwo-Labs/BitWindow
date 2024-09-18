extends Control

const URL_GRPCURL : String = "https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_linux_x86_64.tar.gz"
const URL_GRPCURL_300_301_PROTO : String = "https://raw.githubusercontent.com/LayerTwo-Labs/bip300301_enforcer_proto/master/proto/validator.proto"

const DEBUG_REQUESTS : bool = false

# Bitcoin RPC requests 
@onready var http_rpc_btc_get_block_count: HTTPRequest = $RPCRequests/HTTPRPCBTCGetBlockCount
@onready var http_rpc_btc_get_network_info: HTTPRequest = $RPCRequests/HTTPRPCBTCGetNetworkInfo
@onready var http_rpc_btc_get_mempool_info: HTTPRequest = $RPCRequests/HTTPRPCBTCGetMempoolInfo
@onready var http_rpc_btc_get_blockchain_info: HTTPRequest = $RPCRequests/HTTPRPCBTCGetBlockchainInfo

# Bitcoin Core Wallet RPC Requests
@onready var http_rpc_wallet_core_get_balance: HTTPRequest = $RPCRequests/HTTPRPCWalletCoreGetBalance
@onready var http_rpc_wallet_core_get_new_address: HTTPRequest = $RPCRequests/HTTPRPCWalletCoreGetNewAddress
@onready var http_rpc_wallet_core_send_to_address: HTTPRequest = $RPCRequests/HTTPRPCWalletCoreSendToAddress

# File download http requests
@onready var http_request_download_grpcurl: HTTPRequest = $DownloadRequests/HTTPRequestDownloadGrpcurl

# Signals that should be emitted regularly if connections are working
signal btc_new_block_count(height : int)
signal btc_new_network_info(subversion : String, services : String, connections : int)
signal btc_new_mempool_info(size : int, bytesize : int)
signal btc_new_blockchain_info(bestblockhash : String, bytes : int, warnings : String, time : int)

signal wallet_updated(btc_balance : int)
signal wallet_new_address(address : String)

signal cusf_cat_new_block_count(height : int)
signal cusf_drivechain_new_block_count(height : int)

# Signals that indicate connection failure to one of the backend softwares 
signal btc_rpc_failed()
signal wallet_rpc_failed()
signal cusf_cat_rpc_failed()
signal cusf_drivechain_rpc_failed()

# Set true if we are background downloading grpcurl already
var downloading_grpcurl : bool = false

# Set true if we already checked for and confirmed grpcurl is downloaded
var located_grpcurl : bool = false

# Set true if we are background downloading bip300_301 cusf grpc proto files 
var downloading_grpcurl_300_301_proto : bool = false

# Set true if we already checked for and confirmed bip300/301 proto files 
var located_grpcurl_300_301_proto : bool = false

var core_auth_cookie : String = ""

func _on_button_test_connection_bitcoin_pressed() -> void:
	rpc_bitcoin_getblockcount()
	rpc_wallet_getbalance()


func make_rpc_request(port : int, method: String, params: Variant, http_request: HTTPRequest) -> void:	
	var auth = get_bitcoin_core_cookie()

	if DEBUG_REQUESTS:	
		print("Auth Cookie: ", auth)
		
	var auth_bytes = auth.to_utf8_buffer()
	var auth_encoded = Marshalls.raw_to_base64(auth_bytes)
	var headers: PackedStringArray = []
	headers.push_back("Authorization: Basic " + auth_encoded)
	headers.push_back("content-type: application/json")
	
	var jsonrpc := JSONRPC.new()
	var req = jsonrpc.make_request(method, params, 1)
	
	http_request.request(str("http://", auth, "@127.0.0.1:", str(port)), headers, HTTPClient.METHOD_POST, JSON.stringify(req))


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
	# TODO check which wallet type is selected and contact that
	# For now use bitcoin core wallet
	make_rpc_request($"/root/UserSettings".rpc_port_wallet, "getbalance", [], http_rpc_wallet_core_get_balance)
	
	
func rpc_wallet_getnewaddress() -> void:
	# TODO check which wallet type is selected and contact that
	# For now use bitcoin core wallet
	make_rpc_request($"/root/UserSettings".rpc_port_wallet, "getnewaddress", [], http_rpc_wallet_core_get_new_address)
	
	
func rpc_wallet_sendtoaddress(address : String, amount : String) -> void:
	# TODO check which wallet type is selected and contact that
	# For now use bitcoin core wallet
	make_rpc_request($"/root/UserSettings".rpc_port_wallet, "sendtoaddress", [address, amount], http_rpc_wallet_core_send_to_address)


func have_grpcurl() -> bool:
	if located_grpcurl:
		return true
	
	if !FileAccess.file_exists("user://grpcurl"):
		return false
	
	located_grpcurl = true
	return true


func download_grpcurl() -> void:
	if downloading_grpcurl:
		return
		
	downloading_grpcurl = true
	
	$DownloadRequests/HTTPRequestDownloadGrpcurl.request(URL_GRPCURL)


func extract_grpcurl() -> void:
	var user_dir : String = OS.get_user_data_dir() 
	var ret : int = OS.execute("tar", ["-xzf", str(user_dir, "/grpcurl.tar.gz"), "-C", user_dir])
	if ret != OK:
		printerr("Failed to extract grpcurl")


func have_gprcurl_300_301_proto():
	if located_grpcurl_300_301_proto:
		return true
	
	if !FileAccess.file_exists("user://validator.proto"):
		return false
	
	located_grpcurl_300_301_proto = true
	return true
	
	
func download_gprcurl_300_301_proto():
	if downloading_grpcurl_300_301_proto:
		return
		
	downloading_grpcurl_300_301_proto = true
	
	$DownloadRequests/HTTPRequestDownloadGrpcurl300301Proto.request(URL_GRPCURL_300_301_PROTO)


func get_bitcoin_core_cookie() -> String:
	if !core_auth_cookie.is_empty():
		return core_auth_cookie
	
	var cookie_path : String = str($"/root/UserSettings".directory_bitcoin, "/regtest/.cookie")
	if !FileAccess.file_exists(cookie_path):
		return ""
		
	var file = FileAccess.open(cookie_path, FileAccess.READ)
		
	core_auth_cookie = file.get_as_text()
	
	return core_auth_cookie


func _on_httprpcbtc_get_block_count_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	var height : int = 0
	if res.has("result"):
		if DEBUG_REQUESTS:
			print_debug("Result: ", res.result)
		height = res.result
		btc_new_block_count.emit(height)
	else:
		if DEBUG_REQUESTS:
			print_debug("result error")
		btc_rpc_failed.emit()


func _on_httprpcbtc_get_network_info_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	if res.has("result"):
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
		if DEBUG_REQUESTS:
			print_debug("result error")
		btc_rpc_failed.emit()
		
		
func _on_http_rpc_btc_get_mempool_info_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	if res.has("result"):
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
		if DEBUG_REQUESTS:
			print_debug("result error")
		btc_rpc_failed.emit()


func _on_http_rpc_btc_get_blockchain_info_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	if res.has("result"):
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
		if DEBUG_REQUESTS:
			print_debug("result error")
		btc_rpc_failed.emit()


func _on_http_rpc_wallet_core_get_balance_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	var balance : int = 0
	if res.has("result"):
		#print_debug("Result: ", res.result)
		balance = res.result
		wallet_updated.emit(balance)
	else:
		if DEBUG_REQUESTS:
			print_debug("result error")
		wallet_rpc_failed.emit()


func _on_http_rpc_wallet_core_get_new_address_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	var address : String = ""
	if res.has("result"):
		#print_debug("Result: ", res.result)
		address = res.result
		#wallet_updated.emit(balance)
		#print_debug("new addr: ", address)
		wallet_new_address.emit(address)
	else:
		if DEBUG_REQUESTS:
			print_debug("result error")
		wallet_rpc_failed.emit()


func _on_http_rpc_wallet_core_send_to_address_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var res = parse_rpc_result(response_code, body)
	var txid : String = ""
	if res.has("result"):
		print_debug("Result: ", res.result)
		txid = res.result
		#wallet_updated.emit(balance)
	else:
		if DEBUG_REQUESTS:
			print_debug("result error")
		wallet_rpc_failed.emit()


func _on_http_request_download_grpcurl_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != OK:
		printerr("Failed to download grpcurl")
		return 
	
	if DEBUG_REQUESTS:
		print("res ", result)
		print("code ", response_code)
		print("Downloaded grpcurl tarball")
	
	extract_grpcurl()


func _on_http_request_download_grpcurl_300301_proto_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != OK:
		printerr("Failed to download grpcurl 300 301 proto")
