extends Node

const DEFAULT_BITCOIN_RPC_PORT : int = 8332
const DEFAULT_WALLET_RPC_PORT : int = -1 # TODO currently unknown
const DEFAULT_CUSF_CAT_RPC_PORT : int = -1   # TODO currently unknown
const DEFAULT_CUSF_DRIVECHAIN_RPC_PORT : int = -1   # TODO currently unknown

var rpc_user : String = ""
var rpc_pass : String = ""

var rpc_port_bitcoin : int = DEFAULT_BITCOIN_RPC_PORT
var rpc_port_wallet : int = DEFAULT_WALLET_RPC_PORT
var rpc_port_cusf_cat : int = DEFAULT_CUSF_CAT_RPC_PORT
var rpc_port_cusf_drivechain : int = DEFAULT_CUSF_DRIVECHAIN_RPC_PORT


func load_settings() -> void:
	if !FileAccess.file_exists("user://user_settings.dat"):
		return
		
	var file = FileAccess.open("user://user_settings.dat", FileAccess.READ)
	
	rpc_user = file.get_var()
	rpc_pass = file.get_var()
	rpc_port_bitcoin = file.get_var()
	rpc_port_wallet = file.get_var()
	rpc_port_cusf_cat = file.get_var()
	rpc_port_cusf_drivechain = file.get_var()
	
	
func save_settings() -> void:
	var file = FileAccess.open("user://user_settings.dat", FileAccess.WRITE)
	
	file.store_var(rpc_user)
	file.store_var(rpc_pass)
	file.store_var(rpc_port_bitcoin)
	file.store_var(rpc_port_wallet)
	file.store_var(rpc_port_cusf_cat)
	file.store_var(rpc_port_cusf_drivechain)
