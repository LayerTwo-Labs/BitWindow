extends Node

const DEFAULT_BITCOIN_RPC_PORT : int = 18443
const DEFAULT_WALLET_RPC_PORT : int = 18443
const DEFAULT_CUSF_CAT_RPC_PORT : int = -1 # TODO currently unknown
const DEFAULT_CUSF_DRIVECHAIN_RPC_PORT : int = 50051 
const DEFAULT_BITCOIN_DATA_DIR : String = "/home/.bitcoin" 

var rpc_port_bitcoin : int = DEFAULT_BITCOIN_RPC_PORT
var rpc_port_wallet : int = DEFAULT_WALLET_RPC_PORT
var rpc_port_cusf_cat : int = DEFAULT_CUSF_CAT_RPC_PORT
var rpc_port_cusf_drivechain : int = DEFAULT_CUSF_DRIVECHAIN_RPC_PORT

var directory_bitcoin : String = DEFAULT_BITCOIN_DATA_DIR

var address_book = []

func load_settings() -> void:
	if !FileAccess.file_exists("user://user_settings.dat"):
		return
		
	var file = FileAccess.open("user://user_settings.dat", FileAccess.READ)
	
	rpc_port_bitcoin = file.get_var()
	rpc_port_wallet = file.get_var()
	rpc_port_cusf_cat = file.get_var()
	rpc_port_cusf_drivechain = file.get_var()
	directory_bitcoin = file.get_var()
	
	
func save_settings() -> void:
	var file = FileAccess.open("user://user_settings.dat", FileAccess.WRITE)
	
	file.store_var(rpc_port_bitcoin)
	file.store_var(rpc_port_wallet)
	file.store_var(rpc_port_cusf_cat)
	file.store_var(rpc_port_cusf_drivechain)
	file.store_var(directory_bitcoin)


func load_address_book() -> void:
	if !FileAccess.file_exists("user://address_book.dat"):
		return
		
	var file = FileAccess.open("user://address_book.dat", FileAccess.READ)
	
	address_book = file.get_var()


func save_address_book() -> void:
	var file = FileAccess.open("user://address_book.dat", FileAccess.WRITE)
	
	file.store_var(address_book)
