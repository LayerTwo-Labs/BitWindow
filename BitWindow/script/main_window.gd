extends Control

func _ready() -> void:
	# For network code debugging, set the server node visible
	$Server.visible = true
	
	
func _on_server_btc_new_block_count(height: int) -> void:
	$LabelDebugBlockCount.text = str("Bitcoin block count: ", height)
