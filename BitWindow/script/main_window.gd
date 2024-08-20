extends Control

func _ready() -> void:
	# For network code debugging, set the server node visible
	$Server.visible = true
	
	
func _on_server_btc_new_block_count(height: int) -> void:
	$VBoxContainer/HBoxContainerBottomStatus/PanelContainer/LabelNumBlocks.text = str("Bitcoin block count: ", height)


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
