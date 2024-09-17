extends Window

signal address_selected(address : String)

func _ready() -> void:
	call_deferred("load_addresses")


func _on_close_requested() -> void:
	queue_free()


func load_addresses() -> void:
	$VBoxContainer/ItemList.clear()
	$"/root/UserSettings".load_address_book()
	for address in $"/root/UserSettings".address_book:
		$VBoxContainer/ItemList.add_item(address)
	

func _on_button_save_pressed() -> void:
	$"/root/UserSettings".address_book.push_back($VBoxContainer/HBoxContainer/LineEditNewAddress.text)
	$"/root/UserSettings".save_address_book()
	load_addresses()


func _on_item_list_item_activated(index: int) -> void:
	address_selected.emit($VBoxContainer/ItemList.get_item_text(index))
	queue_free()
