extends Control

const BITCOIN_UPDATE_DELAY : int = 10
const WALLET_UPDATE_DELAY : int = 10
const CUSF_UPDATE_DELAY : int = 10

var connected_btc : bool = false
var connected_wallet : bool = false
var connected_cusf : bool = false

var timer_bitcoin_update = null
var timer_wallet_update = null
var timer_cusf_update = null

func _ready() -> void:
	# For network code debugging, set the server node visible
	$Server.visible = true
	
	# Create bitcoin update timer
	timer_bitcoin_update = Timer.new()
	add_child(timer_bitcoin_update)
	timer_bitcoin_update.connect("timeout", update_bitcoin_data)
	
	timer_bitcoin_update.start(BITCOIN_UPDATE_DELAY)
	
	# Create wallet update timer
	timer_wallet_update = Timer.new()
	add_child(timer_wallet_update)
	timer_wallet_update.connect("timeout", update_wallet_data)
	
	timer_wallet_update.start(WALLET_UPDATE_DELAY)
	
	# Create bitcoin update timer
	timer_cusf_update = Timer.new()
	add_child(timer_cusf_update)
	timer_cusf_update.connect("timeout", update_cusf_data)
	
	timer_cusf_update.start(CUSF_UPDATE_DELAY)
	
	
	call_deferred("display_connection_status")


func _on_server_btc_new_block_count(height: int) -> void:
	connected_btc = true
	$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/LabelNumBlocks.text = str("Blocks: ", height)
	display_connection_status()


func _on_server_cusf_new_block_count(_height: int) -> void:
	connected_cusf = true
	display_connection_status()


func _on_server_wallet_updated(_btc_balance: int) -> void:
	connected_wallet = true
	display_connection_status()
	
	
func _on_server_btc_rpc_failed() -> void:
	connected_btc = false
	display_connection_status()
	

func _on_server_wallet_rpc_failed() -> void:
	connected_wallet = false
	display_connection_status()


func _on_server_cusf_rpc_failed() -> void:
	connected_cusf = false
	display_connection_status()


func _on_button_overview_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/OverviewPage.visible = true
	else:
		$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/OverviewPage.visible = false


func _on_button_wallet_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/WalletPage.visible = true
	else:
		$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/WalletPage.visible = false


func _on_button_sidechains_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage.visible = true
	else:
		$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage.visible = false


func _on_button_settings_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SettingPage.visible = true
	else:
		$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SettingPage.visible = false


func display_connection_status() -> void:
	if connected_btc:
		$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/TextureRectBitcoinNotConnected.visible = false
		$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/TextureRectBitcoinConnected.visible = true
	else:
		$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/TextureRectBitcoinNotConnected.visible = true
		$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/TextureRectBitcoinConnected.visible = false

	if connected_wallet:
		$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/TextureRectWalletNotConnected.visible = false
		$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/TextureRectWalletConnected.visible = true
	else:
		$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/TextureRectWalletNotConnected.visible = true
		$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/TextureRectWalletConnected.visible = false
		
	if connected_cusf:
		$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/TextureRectCUSFNotConnected.visible = false
		$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/TextureRectCUSFConnected.visible = true
	else:
		$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/TextureRectCUSFNotConnected.visible = true
		$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/TextureRectCUSFConnected.visible = false


func update_bitcoin_data() -> void:
	$Server.rpc_bitcoin_getblockcount()


func update_wallet_data() -> void:
	$Server.rpc_wallet_getbalance()


func update_cusf_data() -> void:
	$Server.rpc_cusf_getblockcount()
