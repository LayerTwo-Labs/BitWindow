extends Control

const BITCOIN_UPDATE_DELAY : int = 1
const WALLET_UPDATE_DELAY : int = 1
const CUSF_UPDATE_DELAY : int = 1

var connected_btc : bool = false
var connected_wallet : bool = false
var connected_cusf : bool = false

var timer_bitcoin_update = null
var timer_wallet_update = null
var timer_cusf_update = null

var block_height : int = 0

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
	call_deferred("load_user_settings")


func _on_server_btc_new_block_count(height: int) -> void:
	connected_btc = true
	block_height = height
	display_connection_status()
	
	
func _on_server_btc_new_blockchain_info(bestblockhash: String, bytes: int, warnings: String, time: int) -> void:
	$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/LabelNumBlocks.text = str("Blocks: ", block_height)
	
	var block_panel_text : String = str("Bitcoin Blocks:\n", block_height, "\nLast block time:\n", time)
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/OverviewPage/GridContainer/PanelContainerBlocks/VBoxContainer/LabelBlocks.text = block_panel_text

	var best_block_text = str("Best Block:\n", bestblockhash)
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/OverviewPage/GridContainer/PanelContainerNetworkStats/VBoxContainer/LabelBestBlock.text = best_block_text

	var chain_size_text = str("Blockchain size on disk: ", bytes, " Bytes")
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/OverviewPage/GridContainer/PanelContainerNetworkStats/VBoxContainer/LabelChainSize.text = chain_size_text

	var warnings_text = str("Warnings: ", "None" if warnings.is_empty() else warnings)
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/OverviewPage/GridContainer/PanelContainerNetworkStats/VBoxContainer/LabelWarnings.text = warnings_text


func _on_server_btc_new_mempool_info(ntx: int, bytesize: int) -> void:
	var mempool_size_text = str("Mempool Transactions:\n", ntx)
	var mempool_bytes_text = str("Mempool Size:\n", bytesize, " Bytes")
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/OverviewPage/GridContainer/PanelContainerMempool/VBoxContainer/LabelMempoolSize.text = mempool_size_text
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/OverviewPage/GridContainer/PanelContainerMempool/VBoxContainer/LabelMempoolByteSize.text = mempool_bytes_text
	
	
func _on_server_btc_new_network_info(subversion: String, services: String, connections: int) -> void:
	var version_text = str("Bitcoin Node: ", subversion)
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/OverviewPage/GridContainer/PanelContainerNetworkStats/VBoxContainer/LabelBitcoinVersion.text = version_text
	
	var service_text = str("Services: ", services)
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/OverviewPage/GridContainer/PanelContainerNetworkStats/VBoxContainer/LabelBitcoinServices.text = service_text
	
	var peers_text = str("Peers: ", connections)
	$MarginContainer/VBoxContainer/PanelContainer/HBoxContainerBottomStatus/LabelPeers.text = peers_text


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


func _on_button_cusf_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/CUSFPage.visible = true
	else:
		$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/CUSFPage.visible = false


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
	$Server.rpc_bitcoin_getnetworkinfo()
	$Server.rpc_bitcoin_getmempoolinfo()
	$Server.rpc_bitcoin_getblockchaininfo()


func update_wallet_data() -> void:
	$Server.rpc_wallet_getbalance()


func update_cusf_data() -> void:
	$Server.rpc_cusf_cat_getblockcount()
	$Server.rpc_cusf_drivechain_getblockcount()


#region Settings Page

func load_user_settings() -> void:
	$"/root/UserSettings".load_settings()
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SettingPage/VBoxContainer/HBoxContainer4/LineEditRPCUser.text = $"/root/UserSettings".rpc_user
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SettingPage/VBoxContainer/HBoxContainer4/LineEditRPCPass.text = $"/root/UserSettings".rpc_pass

	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SettingPage/VBoxContainer/HBoxContainer/SpinBoxBitcoinRPCPort.value = $"/root/UserSettings".rpc_port_bitcoin
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SettingPage/VBoxContainer/HBoxContainer2/SpinBoxWalletRPCPort.value = $"/root/UserSettings".rpc_port_wallet
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SettingPage/VBoxContainer/HBoxContainer3/SpinBoxCUSFCATPort.value = $"/root/UserSettings".rpc_port_cusf_cat
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SettingPage/VBoxContainer/HBoxContainer5/SpinBoxCUSFDRIVECHAINPort.value = $"/root/UserSettings".rpc_port_cusf_drivechain
	
	
func _on_line_edit_rpc_user_text_changed(new_text: String) -> void:
	$"/root/UserSettings".rpc_user = new_text
	$"/root/UserSettings".save_settings()


func _on_line_edit_rpc_pass_text_changed(new_text: String) -> void:
	$"/root/UserSettings".rpc_pass = new_text
	$"/root/UserSettings".save_settings()


func _on_spin_box_bitcoin_rpc_port_value_changed(value: float) -> void:
	$"/root/UserSettings".rpc_port_bitcoin = value
	$"/root/UserSettings".save_settings()


func _on_spin_box_wallet_rpc_port_value_changed(value: float) -> void:
	$"/root/UserSettings".rpc_port_wallet = value
	$"/root/UserSettings".save_settings()
	
	
func _on_spin_box_cusf_cat_port_value_changed(value: float) -> void:
	$"/root/UserSettings".rpc_port_cusf_cat = value
	$"/root/UserSettings".save_settings()


func _on_spin_box_cusf_drivechain_port_value_changed(value: float) -> void:
	$"/root/UserSettings".rpc_port_cusf_drivechain = value
	$"/root/UserSettings".save_settings()

#endregion


#region Sidechain Page

func _on_button_propose_sidechain_pressed() -> void:
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainOverview.visible = false
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainProposal.visible = true


func _on_button_sidechain_proposal_go_back_pressed() -> void:
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainOverview.visible = true
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainProposal.visible = false


func _on_button_sidechain_details_go_back_pressed() -> void:
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainOverview.visible = true
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainDetails.visible = false


func _on_button_withdrawal_settings_go_back_pressed() -> void:
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainOverview.visible = true
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainWithdrawalSettings.visible = false


func _on_button_sidechain_activation_go_back_pressed() -> void:
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainOverview.visible = true
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainActivationSettings.visible = false


func _on_item_list_sidechains_item_activated(index: int) -> void:
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainOverview.visible = false
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainDetails.visible = true


func _on_button_set_proposal_votes_pressed() -> void:
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainOverview.visible = false
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainActivationSettings.visible = true


func _on_button_set_withdrawal_votes_pressed() -> void:
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainOverview.visible = false
	$MarginContainer/VBoxContainer/HBoxContainerPageAndPageButtons/PanelContainerPages/SidechainPage/SidechainWithdrawalSettings.visible = true


func _on_button_create_sidechain_proposal_pressed() -> void:
	# TODO confirm
	pass # Replace with function body.


#endregion
